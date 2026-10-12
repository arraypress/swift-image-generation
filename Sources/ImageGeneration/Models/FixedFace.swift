//
//  FixedFace.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

/// What the face fix did to one face, measured on the result.
public struct FixedFace: Sendable, Equatable, Codable {

    /// The face's box in the picture, top-left origin: x, y, width, height.
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int

    /// Vision's face capture quality before and after, 0…1.
    public let qualityBefore: Float?
    public let qualityAfter: Float?

    /// Whether the redraw went into the picture. `false` when it rated
    /// worse than the original and the original was kept.
    public let kept: Bool

    /// How far the redrawn face moved from where it was, in the picture's
    /// pixels: more than a few and the paste-back would ghost.
    public let shift: Double?

    /// The largest change, 0–255, outside the face's region (0 = untouched).
    public let untouchedMaxDifference: Int

    /// The redraw's time.
    public let seconds: Double

    public init(x: Int, y: Int, width: Int, height: Int, qualityBefore: Float?, qualityAfter: Float?, kept: Bool,
                shift: Double?, untouchedMaxDifference: Int, seconds: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.qualityBefore = qualityBefore
        self.qualityAfter = qualityAfter
        self.kept = kept
        self.shift = shift
        self.untouchedMaxDifference = untouchedMaxDifference
        self.seconds = seconds
    }
}
