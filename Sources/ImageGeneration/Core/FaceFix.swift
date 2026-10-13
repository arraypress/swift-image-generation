//
//  FaceFix.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Small faces come out melted: a full-length figure in a 1024 picture has
//  a face of about 60 px, too few for either model to draw eyes in. The fix
//  is the one portrait tools call a "detailer": find each small face, give
//  the edit model a square around it at the model's full 1024, so the face
//  is drawn with sixteen times the pixels, then put back only a soft oval
//  over the face. Everything outside the oval stays the original's, byte for
//  byte, and a redraw that Vision rates worse than the face it replaces is
//  thrown away.
//

import CoreGraphics
import Foundation

public extension ImageGenerator {

    /// Finds the faces in `image` that Vision can see, without changing anything.
    static func faces(in image: CGImage) throws(ImageGenerationError) -> [DetectedFace] {
        try FaceFinder.faces(in: image)
    }

    /// The faces ``fixFaces(in:prompt:seed:options:allowText:progress:)``
    /// would redraw — a fraction of a second, no model — so a caller can
    /// skip loading the edit model when there are none.
    static func smallFaces(in image: CGImage, options: FaceFixOptions = .standard) throws(ImageGenerationError) -> [DetectedFace] {
        try FaceFinder.faces(in: image).filter {
            FacePlan.needsFix($0, imageWidth: image.width, imageHeight: image.height, options: options)
        }
    }

    /// Redraws the small faces in `image` at the model's full size and puts
    /// them back — FLUX.2 Klein only (it edits; SANA cannot).
    ///
    /// - Parameters:
    ///   - image: Any picture, from either model or neither.
    ///   - prompt: The prompt the picture was made from, so the redrawn face
    ///     keeps its light and style.
    ///   - seed: The seed for every redraw: the same picture, prompt and seed
    ///     fix the same way.
    ///   - options: Which faces and how much room; measured defaults.
    ///   - references: The pictures the original was drawn from (a face to
    ///     keep, up to three): the redraw sees them too, so it redraws that
    ///     person rather than inventing one.
    ///   - person: A trained person the picture was drawn with: the redraw loads
    ///     them through the editing slot, so their face is redrawn as theirs.
    ///   - progress: Called after each denoising step with (face, faces, step, steps).
    /// - Returns: The picture and a report per small face found; the picture
    ///   unchanged and no report when there is none.
    func fixFaces(in image: CGImage, prompt: String, seed: UInt32, options: FaceFixOptions = .standard,
                  references: [CGImage] = [], person: Person? = nil, allowText: Bool = false,
                  progress: (@Sendable (Int, Int, Int, Int) -> Void)? = nil)
        async throws(ImageGenerationError) -> FaceFixResult {
        let width = image.width, height = image.height
        let small = try Self.smallFaces(in: image, options: options)
        guard !small.isEmpty else { return FaceFixResult(image: image, faces: []) }
        let instruction = FacePlan.instruction(for: prompt, withReferences: !references.isEmpty)
        var current = image
        var reports: [FixedFace] = []
        for (index, face) in small.enumerated() {
            let plan = FacePlan.plan(for: face.box, imageWidth: width, imageHeight: height, context: options.context)
            let mask = FacePlan.mask(for: face.box, imageWidth: width, imageHeight: height)
            let square = try MaskedEdit.source(current, plan: plan, size: size.width)
            // Below 1 the redraw starts from the face itself, so it keeps more
            // of who it was; at 1 the instruction alone keeps the composition.
            let made = try await edit(square, instruction, seed: seed, strength: options.strength, allowText: allowText,
                                      references: references, person: person) { step, steps in
                progress?(index + 1, small.count, step, steps)
            }
            let (candidate, report) = try MaskedEdit.composite(original: current, edited: made.image,
                                                                masks: [mask], plan: plan)
            // Judge the redraw where it landed, and how far the face moved
            // inside the square (a moved face ghosts against the oval's edge).
            let after = FaceFinder.nearest(to: face.box, in: try FaceFinder.faces(in: candidate))
            let shift = Self.shift(of: face.box, original: square, edited: made.image, plan: plan)
            let better = (after?.quality ?? 0) >= (face.quality ?? 0)
            let kept = better || !options.keepsOnlyImprovements
            if kept { current = candidate }
            reports.append(FixedFace(x: Int(face.box.minX), y: Int(face.box.minY), width: Int(face.box.width),
                                     height: Int(face.box.height), qualityBefore: face.quality,
                                     qualityAfter: after?.quality, kept: kept, shift: shift,
                                     untouchedMaxDifference: report.untouchedMaxDifference, seconds: made.seconds))
        }
        return FaceFixResult(image: current, faces: reports)
    }

    /// How far the face moved in the redraw, in the picture's pixels: the
    /// distance between the face Vision finds in the square before and
    /// after. `nil` when either has no face to compare.
    private static func shift(of box: CGRect, original: CGImage, edited: CGImage, plan: MaskedEditPlan) -> Double? {
        guard let before = try? FaceFinder.faces(in: original).first,
              let after = try? FaceFinder.faces(in: edited).first else { return nil }
        let scaleBefore = Double(plan.side) / Double(original.width)
        let scaleAfter = Double(plan.side) / Double(edited.width)
        let dx = Double(after.box.midX) * scaleAfter - Double(before.box.midX) * scaleBefore
        let dy = Double(after.box.midY) * scaleAfter - Double(before.box.midY) * scaleBefore
        return (hypot(dx, dy) * 10).rounded() / 10
    }
}
