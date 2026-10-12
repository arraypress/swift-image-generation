//
//  DetectedFace.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import CoreGraphics

/// A face Vision found: where, how sure it is, and how well the face is
/// drawn (Vision's capture quality, 0…1 — a melted face scores low).
public struct DetectedFace: Sendable, Equatable {

    /// The face, in the picture's pixels from the top-left.
    public let box: CGRect

    /// Vision's confidence that this is a face, 0…1.
    public let confidence: Float

    /// Vision's face capture quality, 0…1; `nil` when it gave none.
    public let quality: Float?

    public init(box: CGRect, confidence: Float, quality: Float?) {
        self.box = box
        self.confidence = confidence
        self.quality = quality
    }
}
