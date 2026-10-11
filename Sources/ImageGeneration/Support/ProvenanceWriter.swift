//
//  ProvenanceWriter.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Every picture says what it is. The IPTC digital-source type
//  `trainedAlgorithmicMedia` is the standard "made by a generative model"
//  marker; ImageIO writes it into PNG, JPEG and HEIC and reads it back, and
//  exiftool confirms it (measured 2026-10-11). The model goes in IPTC's
//  AISystemUsed and the tool in xmp:CreatorTool. The prompt is written only
//  when asked: it can be private. The macOS 27 SDK has no C2PA API, so
//  signed content credentials are out of reach without a third-party library.
//

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

enum ProvenanceWriter {

    static let digitalSourceType = "http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia"
    static let iptcExtension = "http://iptc.org/std/Iptc4xmpExt/2008-02-29/"
    static let xmpBasic = "http://ns.adobe.com/xap/1.0/"

    /// The format a path's extension names, or `nil` for one this does not write.
    static func type(for url: URL) -> UTType? {
        switch url.pathExtension.lowercased() {
        case "png": .png
        case "jpg", "jpeg": .jpeg
        case "heic": .heic
        default: nil
        }
    }

    /// The metadata a generated picture carries.
    static func metadata(model: GenerationModel, generator: String, prompt: String?) -> CGImageMetadata {
        let meta = CGImageMetadataCreateMutable()
        _ = CGImageMetadataSetValueMatchingImageProperty(meta, kCGImagePropertyIPTCDictionary,
                                                         kCGImagePropertyIPTCExtDigitalSourceType,
                                                         digitalSourceType as CFString)
        var error: Unmanaged<CFError>?
        _ = CGImageMetadataRegisterNamespaceForPrefix(meta, iptcExtension as CFString, "Iptc4xmpExt" as CFString, &error)
        _ = CGImageMetadataSetValueWithPath(meta, nil, "Iptc4xmpExt:AISystemUsed" as CFString, model.displayName as CFString)
        if let prompt {
            _ = CGImageMetadataSetValueWithPath(meta, nil, "Iptc4xmpExt:AIPromptInformation" as CFString, prompt as CFString)
        }
        _ = CGImageMetadataSetValueWithPath(meta, nil, "xmp:CreatorTool" as CFString, generator as CFString)
        return meta
    }

    /// Writes `image` to `url` with the provenance metadata.
    static func write(_ image: CGImage, to url: URL, model: GenerationModel, generator: String,
                      prompt: String?) throws(ImageGenerationError) {
        guard let type = type(for: url) else {
            throw .writeFailed("\(url.lastPathComponent): write .png, .jpg or .heic")
        }
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, type.identifier as CFString, 1, nil) else {
            throw .writeFailed("cannot create \(url.path)")
        }
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: 0.92]
        CGImageDestinationAddImageAndMetadata(destination, image,
                                              metadata(model: model, generator: generator, prompt: prompt),
                                              options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw .writeFailed("cannot finish \(url.path)") }
    }

    /// The digital-source type a file carries, if any — for checking.
    static func digitalSourceType(of url: URL) -> String? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let meta = CGImageSourceCopyMetadataAtIndex(source, 0, nil),
              let tag = CGImageMetadataCopyTagMatchingImageProperty(meta, kCGImagePropertyIPTCDictionary,
                                                                    kCGImagePropertyIPTCExtDigitalSourceType) else {
            return nil
        }
        return CGImageMetadataTagCopyValue(tag) as? String
    }
}
