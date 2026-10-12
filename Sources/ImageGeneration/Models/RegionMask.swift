//
//  RegionMask.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

/// Where a masked edit may change a picture: 0 outside, 255 inside, row-major
/// from the top-left, at the picture's own size (a mask one pixel off, as a
/// segmenter can return, is resized to fit).
public struct RegionMask: Sendable, Equatable {

    /// What the mask covers, as the caller named it ("hair", "glasses frame").
    public let name: String
    public let width: Int
    public let height: Int
    public let pixels: [UInt8]

    /// Whether the edit's own detail replaces the original's here. `false`
    /// (the default) keeps the original's fine detail — skin texture, eyes,
    /// fabric weave — and takes only the edit's colour and shading: right for
    /// a recolour or relight. `true` is for content that is genuinely removed
    /// or added — the opaque frames of glasses, an object taken away — where
    /// there is no original detail worth keeping.
    public let replaces: Bool

    public init(name: String, width: Int, height: Int, pixels: [UInt8], replaces: Bool = false) {
        self.name = name
        self.width = width
        self.height = height
        self.pixels = pixels
        self.replaces = replaces
    }
}
