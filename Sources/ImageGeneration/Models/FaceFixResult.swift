//
//  FaceFixResult.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import CoreGraphics

/// A picture after the face fix, and what happened to each face.
public struct FaceFixResult: Sendable {

    /// The picture: the original's pixels everywhere but the redrawn faces.
    public let image: CGImage

    /// Each small face found, in the order redrawn (largest first).
    public let faces: [FixedFace]

    public init(image: CGImage, faces: [FixedFace]) {
        self.image = image
        self.faces = faces
    }
}
