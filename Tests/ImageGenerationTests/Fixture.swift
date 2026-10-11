//
//  Fixture.swift
//  ImageGenerationTests
//
//  Created by David Sherlock on 2026.
//

import CoreGraphics
import Foundation
import ImageIO

enum Fixture {

    /// A flat sRGB picture.
    static func image(width: Int, height: Int) -> CGImage? {
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                      space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.setFillColor(CGColor(srgbRed: 0.2, green: 0.5, blue: 0.8, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }

    /// A folder holding only a metadata.json.
    static func bundle(_ json: String) throws -> URL {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("bundle-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try json.write(to: folder.appendingPathComponent("metadata.json"), atomically: true, encoding: .utf8)
        return folder
    }

    /// A file's XMP, serialised.
    static func xmp(of url: URL) -> String? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let meta = CGImageSourceCopyMetadataAtIndex(source, 0, nil),
              let data = CGImageMetadataCreateXMPData(meta, nil) else { return nil }
        return String(data: data as Data, encoding: .utf8)
    }

    /// A picture's raw pixels, for byte-for-byte comparison.
    static func pixels(_ image: CGImage) -> Data? {
        image.dataProvider?.data as Data?
    }
}
