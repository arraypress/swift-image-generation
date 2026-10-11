//
//  SquareCrop.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import CoreGraphics

/// The centred square of a picture. The pipeline resizes an edit's source to
/// the model's square on its own, which stretches anything that is not
/// square; cropping first keeps proportions.
enum SquareCrop {

    static func centred(_ image: CGImage) -> CGImage {
        let side = min(image.width, image.height)
        guard image.width != image.height else { return image }
        let rect = CGRect(x: (image.width - side) / 2, y: (image.height - side) / 2, width: side, height: side)
        return image.cropping(to: rect) ?? image
    }
}
