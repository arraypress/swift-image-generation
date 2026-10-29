//
//  ImageAspect+Details.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

public extension ImageAspect {

    /// Width and height in pixels. Every side is a multiple of 32: FLUX's
    /// editing deals several references out in half-size quarters.
    var size: (width: Int, height: Int) {
        switch self {
        case .square: (1024, 1024)
        case .landscape: (1344, 768)
        case .vertical: (768, 1344)
        case .portrait: (896, 1120)
        case .classic: (1152, 864)
        case .classicTall: (864, 1152)
        case .photo: (1248, 832)
        case .photoTall: (832, 1248)
        }
    }

    /// Width over height.
    var ratio: Double { Double(size.width) / Double(size.height) }

    /// The named shape whose ratio is within `tolerance` of `width` × `height`'s, or `nil`.
    /// The default 2% names 3840 × 2160 "16:9", though FLUX's own 16:9 size, 1344 × 768,
    /// is 1.75 : 1; the nearest two named shapes (4:5 and 3:4) differ by 6.5%.
    static func matching(width: Int, height: Int, within tolerance: Double = 0.02) -> ImageAspect? {
        guard width > 0, height > 0 else { return nil }
        let ratio = Double(width) / Double(height)
        return allCases.first { abs(log($0.ratio / ratio)) < tolerance }
    }

    /// The folder, inside a SANA export, holding this shape's transformer and
    /// decoder; `nil` for the square export at the top and for shapes SANA
    /// does not have.
    var subfolder: String? {
        switch self {
        case .landscape: "aspect-16x9"
        case .vertical: "aspect-9x16"
        case .portrait: "aspect-4x5"
        case .square, .classic, .classicTall, .photo, .photoTall: nil
        }
    }

    /// This shape's folder in a FLUX export (FLUX.2 Klein 4B, FLUX.3 Klein),
    /// e.g. `shapes/4x3`: its autoencoder, `metadata.json`, and the
    /// transformers fetched for it.
    var shapeFolder: String { "shapes/" + rawValue.replacingOccurrences(of: ":", with: "x") }

    /// The shape among `candidates` nearest a picture's, by the logarithm of
    /// the ratio — 4032 × 3024 is 4:3, a 1080 × 1920 screenshot 9:16.
    static func nearest(width: Int, height: Int, among candidates: [ImageAspect] = allCases) -> ImageAspect {
        AspectMath.nearest(width: width, height: height, among: candidates)
    }
}
