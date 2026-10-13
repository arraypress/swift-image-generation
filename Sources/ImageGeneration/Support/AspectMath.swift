//
//  AspectMath.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Fitting a picture to a shape. An edit keeps the photo's own shape where
//  one is close: the nearest by the logarithm of the ratio (so 4:3 and 3:4
//  are equally far from 1:1), then a centred trim of whatever is left over,
//  which the caller reports — never a surprise crop.
//

import CoreGraphics
import Foundation

enum AspectMath {

    static func nearest(width: Int, height: Int, among candidates: [ImageAspect]) -> ImageAspect {
        guard width > 0, height > 0, !candidates.isEmpty else { return .square }
        let target = log(Double(width) / Double(height))
        return candidates.min { abs(log($0.ratio) - target) < abs(log($1.ratio) - target) } ?? .square
    }

    /// The centred rectangle of a `width` × `height` picture with the ratio
    /// `targetWidth` : `targetHeight`.
    static func centredRect(width: Int, height: Int, targetWidth: Int, targetHeight: Int) -> CGRect {
        let want = Double(targetWidth) / Double(targetHeight)
        let have = Double(width) / Double(height)
        if abs(have - want) < 1e-9 { return CGRect(x: 0, y: 0, width: width, height: height) }
        if have > want {
            let w = Int((Double(height) * want).rounded())
            return CGRect(x: (width - w) / 2, y: 0, width: w, height: height)
        }
        let h = Int((Double(width) / want).rounded())
        return CGRect(x: 0, y: (height - h) / 2, width: width, height: h)
    }

    /// The share of the picture a centred fit trims away, 0…1.
    static func trimmed(width: Int, height: Int, targetWidth: Int, targetHeight: Int) -> Double {
        let rect = centredRect(width: width, height: height, targetWidth: targetWidth, targetHeight: targetHeight)
        return 1 - Double(rect.width * rect.height) / Double(width * height)
    }

    static func centred(_ image: CGImage, width: Int, height: Int) -> CGImage {
        let rect = centredRect(width: image.width, height: image.height, targetWidth: width, targetHeight: height)
        guard rect.width != CGFloat(image.width) || rect.height != CGFloat(image.height) else { return image }
        return image.cropping(to: rect) ?? image
    }
}
