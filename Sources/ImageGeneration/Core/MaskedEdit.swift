//
//  MaskedEdit.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Change one part of a picture and nothing else. The edit model redraws
//  everything it is given, so a masked edit gives it a square around the
//  masked part, then puts back only that part — keeping the original's fine
//  detail there unless a mask says the content is replaced — and copies
//  every other pixel untouched. The steps are public so a caller can put
//  its own enlarging step (an upscaler) between edit and composite.
//

import CoreGraphics
import Foundation

/// Masked edits: plan, source, composite.
public enum MaskedEdit {

    /// The square to edit around `masks` on a `width × height` picture.
    ///
    /// - Throws: ``ImageGenerationError/invalidMask(_:)`` when the masks
    ///   cover nothing.
    public static func plan(_ masks: [RegionMask], imageWidth: Int,
                            imageHeight: Int) throws(ImageGenerationError) -> MaskedEditPlan {
        guard imageWidth > 0, imageHeight > 0 else { throw .invalidMask("the picture has no pixels") }
        guard !masks.isEmpty, let plan = MaskedComposite.plan(masks, imageWidth: imageWidth, imageHeight: imageHeight) else {
            throw .invalidMask("the masks cover nothing")
        }
        return plan
    }

    /// The plan's square of `image`, `size` pixels a side — what to hand
    /// the edit model.
    public static func source(_ image: CGImage, plan: MaskedEditPlan, size: Int) throws(ImageGenerationError) -> CGImage {
        let space = PixelRaster.workingSpace(for: image)
        guard let raster = PixelRaster.render(image, width: image.width, height: image.height, colorSpace: space),
              let square = MaskedComposite.source(raster, plan: plan, size: size) else {
            throw .invalidMask("the picture could not be read for editing")
        }
        return square
    }

    /// `edited` — the edit of ``source(_:plan:size:)``'s square, at any size
    /// — put back into `original` through `masks`.
    ///
    /// - Returns: The result, in the original's colour space and size, and
    ///   the measured report (``MaskedEditReport/untouchedMaxDifference`` is
    ///   0 when every pixel outside the region is the original's).
    public static func composite(original: CGImage, edited: CGImage, masks: [RegionMask],
                                 plan: MaskedEditPlan) throws(ImageGenerationError) -> (image: CGImage, report: MaskedEditReport) {
        guard plan.imageWidth == original.width, plan.imageHeight == original.height else {
            throw .invalidMask("the plan was made for a \(plan.imageWidth)×\(plan.imageHeight) picture")
        }
        let space = PixelRaster.workingSpace(for: original)
        guard let raster = PixelRaster.render(original, width: original.width, height: original.height, colorSpace: space),
              let (result, report) = MaskedComposite.composite(original: raster, edited: edited, masks: masks, plan: plan),
              let image = result.image() else {
            throw .invalidMask("the edit could not be put back")
        }
        return (image, report)
    }
}

public extension ImageGenerator {

    /// Changes only what `masks` cover: plans a square around them, edits
    /// it, enlarges the edit back to the square's size (`enlarge`, e.g. an
    /// upscaler; a high-quality resample when `nil`), and composites it
    /// into `image` (``MaskedEdit/composite(original:edited:masks:plan:)``).
    ///
    /// - Parameters:
    ///   - references: As for ``ImageGenerator/edit(_:_:seed:strength:allowText:steps:references:progress:)``.
    ///   - enlarge: Called with the edit and the square's side when the
    ///     square is larger than the model's; returns a picture at least
    ///     that large.
    /// - Returns: The result at `image`'s size, with the report and plan.
    func edit(_ image: CGImage, _ instruction: String, within masks: [RegionMask], seed: UInt32? = nil,
              strength: Float = 1, allowText: Bool = false, steps: Int? = nil,
              references: [CGImage] = [], person: Person? = nil,
              enlarge: (@Sendable (CGImage, Int) async throws -> CGImage)? = nil,
              progress: (@Sendable (Int, Int) -> Void)? = nil)
        async throws(ImageGenerationError) -> (picture: GeneratedImage, report: MaskedEditReport, plan: MaskedEditPlan) {
        let plan = try MaskedEdit.plan(masks, imageWidth: image.width, imageHeight: image.height)
        let square = try MaskedEdit.source(image, plan: plan, size: size.width)
        let made = try await edit(square, instruction, seed: seed, strength: strength, allowText: allowText,
                                  steps: steps, references: references, person: person, progress: progress)
        var back = made.image
        if plan.side > back.width, let enlarge {
            do { back = try await enlarge(made.image, plan.side) } catch {
                throw .generationFailed("enlarging the edit failed: \(error.localizedDescription)")
            }
        }
        let (result, report) = try MaskedEdit.composite(original: image, edited: back, masks: masks, plan: plan)
        let picture = GeneratedImage(image: result, seed: made.seed, model: made.model, prompt: made.prompt,
                                     promptSent: made.promptSent, edited: true, seconds: made.seconds)
        return (picture, report, plan)
    }
}
