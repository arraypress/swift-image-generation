//
//  FaceFixOptions.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

/// How ``ImageGenerator/fixFaces(in:prompt:seed:options:allowText:progress:)``
/// chooses and redraws faces. The defaults are measured — see the README.
public struct FaceFixOptions: Sendable, Equatable {

    /// The largest face redrawn, as a share of the picture's longer side. A
    /// face bigger than this already had enough pixels to be drawn well —
    /// and redrawing a good face swaps the person: measured, a 119 px face
    /// (0.12) went from melted to clean, while a fine 180 px one (0.18) came
    /// back as a different man for a quality gain of 0.05.
    public var largestFace: Double

    /// The square redrawn around a face, as a multiple of the face's side:
    /// room for the hair, the neck and enough of the scene for the model to
    /// match its light. 3.5 rated best on all three faces measured, ahead of
    /// 2.5 and 2.0.
    public var context: Double

    /// Faces Vision is less sure of than this are left alone.
    public var minimumConfidence: Float

    /// Keep a redraw only when Vision rates the new face at least as well
    /// as the old one; otherwise the original face stays.
    public var keepsOnlyImprovements: Bool

    /// How far a redraw may move from the face it replaces, 0…1 — the edit
    /// strength. 1 redraws from noise, the face square only a reference.
    public var strength: Float

    public init(largestFace: Double = 0.15, context: Double = 3.5,
                minimumConfidence: Float = 0.5, keepsOnlyImprovements: Bool = true, strength: Float = 1) {
        self.largestFace = largestFace
        self.context = context
        self.minimumConfidence = minimumConfidence
        self.keepsOnlyImprovements = keepsOnlyImprovements
        self.strength = strength
    }

    /// The measured defaults.
    public static let standard = FaceFixOptions()
}
