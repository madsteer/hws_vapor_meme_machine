import Routing
import Vapor
import Leaf
import SwiftGD

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let rootDirectory = DirectoryConfig.detect().workDir
    let uploadDirectory = URL(fileURLWithPath: "\(rootDirectory)Public/uploads")
    let originalsDirectory = uploadDirectory.appendingPathComponent("originals")
    let thumbsDirectory = uploadDirectory.appendingPathComponent("thumbs")
    // create an array of the file types we're willing to accept
    let acceptableTypes = [MediaType.png, MediaType.jpeg]

    router.get { req -> Future<View> in
        let fm = FileManager()

        guard let files = try? fm.contentsOfDirectory(at: originalsDirectory, includingPropertiesForKeys: nil) else {
            throw Abort(.internalServerError)
        }

        let visibleFileNames = files.map { $0.lastPathComponent }
            .filter { !$0.hasPrefix(".") }

        let context = ["files": visibleFileNames]
        return try req.view().render("home", context)
    }

    router.post { req -> Future<Response> in
        struct UserFile: Content {
            var upload: [File]
        }

        // pull out the multi-part encoded form data
        return try req.content.decode(UserFile.self).map(to: Response.self) { data in

            // loop over each file in the uploaded array
            for file in data.upload {
                // ensure this image is one of the valid types
                guard let mimeType = file.contentType else { continue }
                guard acceptableTypes.contains(mimeType) else { continue }

                // replace any spaces in filenames with a dash
                let cleanedFilename = file.filename.replacingOccurrences(of: " ", with: "_")

                // convert that into a URL we can write to
                let newURL = originalsDirectory.appendingPathComponent(cleanedFilename)

                // write the full-size original image
                _ = try? file.data.write(to: newURL)

                // create a matching URL in the thumbnails directory
                let thumbURL = thumbsDirectory.appendingPathComponent(cleanedFilename)

                // attempt to load the original into a SwiftGD image
                if let image = Image(url: newURL) {
                    // attempt to resize that down to a thumbnail
                    if let resized = image.resizedTo(width: 300) {
                        // it worked – save it!
                        resized.write(to: thumbURL)
                    }
                }
            }

            return req.redirect(to: "/")
        }
    }
}
