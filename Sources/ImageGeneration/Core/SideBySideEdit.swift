//
//  SideBySideEdit.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  A masked edit that brings something in from another picture without a
//  second picture in: the region and the thing share one canvas, so the
//  model sees both at full resolution — see Support/SideBySide.swift for
//  why, and the measurements.
//

import CoreGraphics
import Foundation

public extension ImageGenerator {

    /// Changes what `masks` cover in `image` using `thing` — a garment on
    /// white, a product — shown beside the region in one picture.
    /// `instruction` should speak of the two sides: "Dress the person on the
    /// left in the jacket shown on the right…". Every pixel outside the
    /// masks stays the original's, as in any masked edit.
    ///
    /// - Parameters:
    ///   - enlarge: Called with the edit's left panel and the panel's height
    ///     in the photo when that is larger than the model's; returns a
    ///     picture at least that large (an upscaler).
    /// - Returns: The result at `image`'s size, with the report and layout.
    func edit(_ image: CGImage, _ instruction: String, within masks: [RegionMask], showing thing: CGImage,
              seed: UInt32? = nil, strength: Float = 1, allowText: Bool = false, steps: Int? = nil,
              person: Person? = nil, enlarge: (@Sendable (CGImage, Int) async throws -> CGImage)? = nil,
              progress: (@Sendable (Int, Int) -> Void)? = nil)
        async throws(ImageGenerationError) -> (picture: GeneratedImage, report: MaskedEditReport, plan: SideBySidePlan) {
        guard size.width == size.height else {
            throw .editingUnavailable("a side-by-side edit needs the square (1:1) editing export")
        }
        guard !masks.isEmpty, let plan = SideBySide.plan(masks, imageWidth: image.width, imageHeight: image.height,
                                                         canvas: size.width) else {
            throw .invalidMask("the masks cover nothing")
        }
        let space = PixelRaster.workingSpace(for: image)
        guard let original = PixelRaster.render(image, width: image.width, height: image.height, colorSpace: space),
              let canvas = SideBySide.canvas(original, thing: thing, plan: plan) else {
            throw .invalidMask("the picture could not be read for editing")
        }
        let made = try await edit(canvas, instruction, seed: seed, strength: strength, allowText: allowText,
                                  steps: steps, references: [], person: person, progress: progress)
        guard var panel = made.image.cropping(to: CGRect(x: 0, y: 0, width: plan.panelWidth, height: plan.canvas)) else {
            throw .generationFailed("the edit came back the wrong size")
        }
        if plan.panel.height > Double(panel.height), let enlarge {
            do { panel = try await enlarge(panel, Int(plan.panel.height.rounded(.up))) } catch {
                throw .generationFailed("enlarging the edit failed: \(error.localizedDescription)")
            }
        }
        guard let square = SideBySide.square(original, panel: panel, plan: plan) else {
            throw .invalidMask("the edit could not be put back")
        }
        let (result, report) = try MaskedEdit.composite(original: image, edited: square, masks: masks, plan: plan.square)
        let picture = GeneratedImage(image: result, seed: made.seed, model: made.model, prompt: made.prompt,
                                     promptSent: made.promptSent, edited: true, seconds: made.seconds)
        return (picture, report, plan)
    }
}
