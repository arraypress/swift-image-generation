//
//  FramedReference.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import CoreGraphics

/// A reference picture as it will go to the model, and what framing did.
public struct FramedReference: Sendable {

    /// The picture to hand the model: the subject on white in a square when
    /// ``framed``, else the picture as it was.
    public let image: CGImage

    /// Whether the picture was cut down to its subject.
    public let framed: Bool

    /// Why it was left alone, when it was: "busy background", "fills the
    /// picture", "no subject found".
    public let reason: String?

    /// The share of the picture's longer side the subject's box spanned, 0…1.
    public let subjectSpan: Double

    /// The border's spread from one colour (OKLab ×100); plain is ≤ 4.
    public let borderSpread: Double
}
