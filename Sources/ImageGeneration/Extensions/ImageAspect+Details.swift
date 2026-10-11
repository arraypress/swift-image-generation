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
        }
    }

    /// The folder, inside a model's export, holding this shape's transformer
    /// and decoder; `nil` for the square export at the top.
    var subfolder: String? {
        switch self {
        case .square: nil
        case .landscape: "aspect-16x9"
        }
    }
}
