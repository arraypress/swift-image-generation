//
//  PixelRaster.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  8-bit RGBA pixels in one colour space. A masked edit works in the
//  original picture's own space, so the pixels it leaves alone come back as
//  the very bytes the picture had; the edit is converted into that space
//  when it is drawn in.
//

import CoreGraphics

/// RGBA, 8 bits a channel, premultiplied last, row-major from the top-left.
struct PixelRaster: Sendable {

    let width: Int
    let height: Int
    var bytes: [UInt8]
    let colorSpace: CGColorSpace

    /// The colour space to work in for `image`: its own when it is an RGB
    /// space a bitmap can be drawn in, else sRGB.
    static func workingSpace(for image: CGImage) -> CGColorSpace {
        if let space = image.colorSpace, space.model == .rgb, space.supportsOutput { return space }
        return CGColorSpace(name: CGColorSpace.sRGB)!
    }

    /// `image` drawn at `width × height` into `colorSpace` — scaled with
    /// high-quality interpolation when the sizes differ.
    static func render(_ image: CGImage, width: Int, height: Int, colorSpace: CGColorSpace) -> PixelRaster? {
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let drawn: Bool = bytes.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                                          bytesPerRow: width * 4, space: colorSpace,
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
            context.interpolationQuality = .high
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        return drawn ? PixelRaster(width: width, height: height, bytes: bytes, colorSpace: colorSpace) : nil
    }

    /// The pixels as a picture.
    func image() -> CGImage? {
        let data = bytes.withUnsafeBufferPointer { CFDataCreate(nil, $0.baseAddress, $0.count) }
        guard let data, let provider = CGDataProvider(data: data) else { return nil }
        return CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4,
                       space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }
}
