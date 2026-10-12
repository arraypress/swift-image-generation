//
//  ImageAspect+Details.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

public extension ImageAspect {

    /// Width and height in pixels.
    var size: (width: Int, height: Int) {
        switch self {
        case .square: (1024, 1024)
        case .landscape: (1344, 768)
        case .vertical: (768, 1344)
        case .portrait: (896, 1120)
        }
    }

    /// The folder, inside a model's export, holding this shape's transformer
    /// and decoder; `nil` for the square export at the top.
    var subfolder: String? {
        switch self {
        case .square: nil
        case .landscape: "aspect-16x9"
        case .vertical: "aspect-9x16"
        case .portrait: "aspect-4x5"
        }
    }
}
