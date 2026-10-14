//
//  ReferenceFraming.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Framing a reference picture around its subject before it goes in — see
//  Support/ReferenceFrame.swift for why and the measurements.
//

import CoreGraphics
import Foundation

/// Reference pictures cut down to what matters in them.
public enum ReferenceFraming {

    /// The margin left around the subject, as a share of its longer side.
    public static let defaultPadding = 0.04

    /// `image` framed around its subject: the masked part on white, centred
    /// in a square — when the picture's background is plain and the subject
    /// does not already fill it. Anything else comes back unchanged, with
    /// the reason.
    ///
    /// - Parameters:
    ///   - mask: The subject, 0–255 at the picture's size (a SAM 3 mask of
    ///     the garment, say); Vision's foreground mask when `nil`.
    ///   - square: Set it in a square (a reference goes to FLUX cropped
    ///     square); `false` keeps its own box's shape, for a side-by-side
    ///     edit's panel, which fits it whole.
    public static func frame(_ image: CGImage, mask: RegionMask? = nil, padding: Double = defaultPadding,
                             square: Bool = true) throws(ImageGenerationError) -> FramedReference {
        let space = PixelRaster.workingSpace(for: image)
        guard let raster = PixelRaster.render(image, width: image.width, height: image.height, colorSpace: space) else {
            throw .generationFailed("the reference picture could not be read")
        }
        let spread = (ReferenceFrame.borderSpread(raster) * 10).rounded() / 10
        func unchanged(_ why: String, span: Double = 1) -> FramedReference {
            FramedReference(image: image, framed: false, reason: why, subjectSpan: span, borderSpread: spread)
        }
        let pixels: [UInt8]
        if let mask {
            pixels = MaskedComposite.fitted(mask, width: image.width, height: image.height)
        } else {
            guard spread <= ReferenceFrame.plainBorderLimit else { return unchanged("busy background") }
            guard let found = try SubjectFinder.mask(in: image) else { return unchanged("no subject found") }
            pixels = found
        }
        guard let box = ReferenceFrame.bounds(pixels, width: image.width, height: image.height) else {
            return unchanged("no subject found")
        }
        let span = (Double(max(box.width, box.height)) / Double(max(image.width, image.height)) * 100).rounded() / 100
        guard spread <= ReferenceFrame.plainBorderLimit else { return unchanged("busy background", span: span) }
        // A square frame gains nothing when the subject already spans the
        // picture; a tight one still trims the empty sides.
        guard !square || ReferenceFrame.worthFraming(borderSpread: spread, box: box, width: image.width, height: image.height) else {
            return unchanged("fills the picture", span: span)
        }
        guard let framed = ReferenceFrame.onWhite(raster, mask: pixels, padding: padding, square: square),
              let picture = framed.image() else {
            return unchanged("no subject found", span: span)
        }
        return FramedReference(image: picture, framed: true, reason: nil, subjectSpan: span, borderSpread: spread)
    }

    /// The picture's main subject as a mask — Vision's foreground, every
    /// instance — or `nil` when it finds none.
    public static func subject(in image: CGImage) throws(ImageGenerationError) -> RegionMask? {
        guard let pixels = try SubjectFinder.mask(in: image) else { return nil }
        return RegionMask(name: "subject", width: image.width, height: image.height, pixels: pixels)
    }

    /// `image` with everything outside `mask` pure white (255, 255, 255),
    /// blended by the mask's soft edge; the same size. A product or a person
    /// on white, the way a shop shows it.
    public static func onWhite(_ image: CGImage, mask: RegionMask) -> CGImage? {
        let space = PixelRaster.workingSpace(for: image)
        guard let raster = PixelRaster.render(image, width: image.width, height: image.height, colorSpace: space) else {
            return nil
        }
        let pixels = MaskedComposite.fitted(mask, width: image.width, height: image.height)
        return ReferenceFrame.whitened(raster, mask: pixels).image()
    }

    /// `image` as given, unframed — for a caller that was asked to send it whole.
    public static func whole(_ image: CGImage, reason: String) -> FramedReference {
        FramedReference(image: image, framed: false, reason: reason, subjectSpan: 1, borderSpread: 0)
    }

    /// The colour of the part of `image` under `mask` in everyday words —
    /// "mustard yellow", "red and white" — or `nil` when the mask is empty.
    public static func colourWords(of image: CGImage, mask: RegionMask) -> String? {
        let space = PixelRaster.workingSpace(for: image)
        guard let raster = PixelRaster.render(image, width: image.width, height: image.height, colorSpace: space) else {
            return nil
        }
        let pixels = MaskedComposite.fitted(mask, width: image.width, height: image.height)
        var colours: [ColourNames.Lab] = []
        let step = max(1, Int((Double(image.width * image.height) / 60_000).squareRoot()))
        for y in stride(from: 0, to: image.height, by: step) {
            for x in stride(from: 0, to: image.width, by: step) where pixels[y * image.width + x] >= 192 {
                let i = (y * image.width + x) * 4
                colours.append(ColourNames.lab(raster.bytes[i], raster.bytes[i + 1], raster.bytes[i + 2]))
            }
        }
        return ColourNames.describe(colours)
    }

    /// Whether the part of `image` under `mask` is striped — its lightness
    /// repeats across the middle, row by row or column by column
    /// (``StripeReader``). A striped garment is named "striped" in a dressing
    /// instruction, with its colours, and asked for its stripes as wide as
    /// shown.
    public static func isStriped(_ image: CGImage, mask: RegionMask) -> Bool {
        let space = PixelRaster.workingSpace(for: image)
        guard let raster = PixelRaster.render(image, width: image.width, height: image.height, colorSpace: space) else {
            return false
        }
        let pixels = MaskedComposite.fitted(mask, width: image.width, height: image.height)
        var lightness = [Double](repeating: .nan, count: image.width * image.height)
        for p in 0..<(image.width * image.height) where pixels[p] >= 128 {
            lightness[p] = ColourNames.lab(raster.bytes[p * 4], raster.bytes[p * 4 + 1], raster.bytes[p * 4 + 2]).l
        }
        return StripeReader.regularity(lightness, width: image.width, height: image.height) >= StripeReader.striped
    }
}
