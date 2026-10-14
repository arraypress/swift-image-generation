//
//  MaskedComposite.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  The arithmetic of a masked edit. Learned the hard way on a portrait,
//  where "edit, then paste through a mask" smoothed the skin and redrew the
//  eyes: inside a mask the result keeps the ORIGINAL's fine detail and takes
//  the edit's colour and shading (low frequencies); only where a mask
//  `replaces` does the edit's own detail come through. Low frequencies are
//  measured with a normalised blur that leaves replaced pixels out — a plain
//  blur pulled the dark of glasses frames into the skin around them as a
//  halo. Every pixel outside the grown, feathered region is copied, so it
//  is the original's byte for byte; at the region's seam the edit's overall
//  shade is matched to the original's (Support/SeamMatch.swift).
//

import CoreGraphics
import Foundation

enum MaskedComposite {

    /// A mask at the picture's size, resized (nearest) when a segmenter's
    /// mask comes back a pixel off.
    static func fitted(_ mask: RegionMask, width: Int, height: Int) -> [UInt8] {
        if mask.width == width, mask.height == height, mask.pixels.count == width * height { return mask.pixels }
        guard mask.width > 0, mask.height > 0, mask.pixels.count == mask.width * mask.height else {
            return [UInt8](repeating: 0, count: width * height)
        }
        var out = [UInt8](repeating: 0, count: width * height)
        for y in 0..<height {
            let sy = min(mask.height - 1, y * mask.height / height)
            for x in 0..<width {
                out[y * width + x] = mask.pixels[sy * mask.width + min(mask.width - 1, x * mask.width / width)]
            }
        }
        return out
    }

    /// The square around everything the masks cover, with room to spare.
    static func plan(_ masks: [RegionMask], imageWidth: Int, imageHeight: Int) -> MaskedEditPlan? {
        var minX = Int.max, minY = Int.max, maxX = -1, maxY = -1
        for mask in masks {
            let pixels = fitted(mask, width: imageWidth, height: imageHeight)
            for y in 0..<imageHeight {
                let base = y * imageWidth
                for x in 0..<imageWidth where pixels[base + x] > 127 {
                    minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
                }
            }
        }
        guard maxX >= 0 else { return nil }
        let longest = max(maxX - minX + 1, maxY - minY + 1)
        let margin = max(32, longest / 5)
        let side = min(max(longest + 2 * margin, 256), max(imageWidth, imageHeight))
        let centreX = (minX + maxX + 1) / 2, centreY = (minY + maxY + 1) / 2
        func place(_ centre: Int, _ length: Int) -> Int {
            side <= length ? min(max(centre - side / 2, 0), length - side) : (length - side) / 2
        }
        return MaskedEditPlan(x: place(centreX, imageWidth), y: place(centreY, imageHeight), side: side,
                              imageWidth: imageWidth, imageHeight: imageHeight)
    }

    /// The plan's square of `original`, `size` pixels a side, in the
    /// original's colour space; parts past the picture's edge repeat the
    /// nearest edge pixel.
    static func source(_ original: PixelRaster, plan: MaskedEditPlan, size: Int) -> CGImage? {
        let side = plan.side
        var square = PixelRaster(width: side, height: side, bytes: [UInt8](repeating: 0, count: side * side * 4),
                                 colorSpace: original.colorSpace)
        for y in 0..<side {
            let sy = min(max(plan.y + y, 0), original.height - 1)
            for x in 0..<side {
                let sx = min(max(plan.x + x, 0), original.width - 1)
                let from = (sy * original.width + sx) * 4, to = (y * side + x) * 4
                square.bytes[to] = original.bytes[from]
                square.bytes[to + 1] = original.bytes[from + 1]
                square.bytes[to + 2] = original.bytes[from + 2]
                square.bytes[to + 3] = original.bytes[from + 3]
            }
        }
        guard let picture = square.image() else { return nil }
        if size == side { return picture }
        return PixelRaster.render(picture, width: size, height: size, colorSpace: original.colorSpace)?.image()
    }

    /// The tuning, in proportion to the square's side (measured on a 1.7k
    /// portrait: grow 10 px, feather σ 7 px, detail split σ 6 px).
    struct Tuning {
        let grow: Int, feather: Double, replaceGrow: Int, detail: Double
        init(side: Int) {
            let s = Double(side)
            grow = max(4, Int(s * 0.006))       // a segmenter misses a few px of edge at any size
            feather = max(1.5, s * 0.004)
            replaceGrow = max(3, Int(s * 0.009))
            detail = max(2, s * 0.0035)
        }
    }

    /// `edited` (the plan's square, any size) put back into `original`
    /// through the masks. Returns the result and the measured report.
    static func composite(original: PixelRaster, edited: CGImage, masks: [RegionMask],
                          plan: MaskedEditPlan) -> (PixelRaster, MaskedEditReport)? {
        let side = plan.side, width = original.width, height = original.height
        guard let edit = PixelRaster.render(edited, width: side, height: side, colorSpace: original.colorSpace) else {
            return nil
        }
        let tuning = Tuning(side: side)
        let count = side * side

        // Masks inside the square; nothing counts past the picture's edge.
        var union = [Float](repeating: 0, count: count), replace = [Float](repeating: 0, count: count)
        for mask in masks {
            let pixels = fitted(mask, width: width, height: height)
            for y in 0..<side {
                let iy = plan.y + y
                guard iy >= 0, iy < height else { continue }
                for x in 0..<side {
                    let ix = plan.x + x
                    guard ix >= 0, ix < width, pixels[iy * width + ix] > 127 else { continue }
                    union[y * side + x] = 1
                    if mask.replaces { replace[y * side + x] = 1 }
                }
            }
        }
        // The region: the mask's own soft edge, plus a grown ring — but only
        // where the original there looks like the masked thing nearby (its
        // fringe, which a segmenter misses), never the background beside it.
        // A plain grown ring let a red jacket's colour bleed onto the wall
        // behind it as a pink glow.
        let core = PlaneMath.blur(union, width: side, height: side, sigma: tuning.feather * 0.5)
        let ring = PlaneMath.blur(PlaneMath.grow(union, width: side, height: side, radius: tuning.grow),
                                  width: side, height: side, sigma: tuning.feather)
        // The original's channels over the square (edges repeated past the picture).
        var planes: [[Float]] = []
        for channel in 0..<3 {
            var o = [Float](repeating: 0, count: count)
            for y in 0..<side {
                let sy = min(max(plan.y + y, 0), height - 1)
                for x in 0..<side {
                    o[y * side + x] = Float(original.bytes[(sy * width + min(max(plan.x + x, 0), width - 1)) * 4 + channel])
                }
            }
            planes.append(o)
        }
        var likeness = [Float](repeating: 1, count: count)
        // What the masked thing looks like near each pixel.
        let nearby = planes.map {
            PlaneMath.normalisedBlur($0, weight: union, width: side, height: side, sigma: Double(tuning.grow) * 2)
        }
        do {
            let spread: Float = 30   // colour distance (0–255 RGB) at which a ring pixel counts ~60%
            for i in 0..<count {
                let dr = planes[0][i] - nearby[0][i], dg = planes[1][i] - nearby[1][i], db = planes[2][i] - nearby[2][i]
                likeness[i] = expf(-(dr * dr + dg * dg + db * db) / (2 * spread * spread))
            }
        }
        var alpha = [Float](repeating: 0, count: count)
        let replaceSoft = PlaneMath.blur(PlaneMath.grow(replace, width: side, height: side, radius: tuning.replaceGrow),
                                         width: side, height: side, sigma: tuning.feather * 0.8)
        let excluded = PlaneMath.blur(PlaneMath.grow(replace, width: side, height: side, radius: tuning.replaceGrow * 2),
                                      width: side, height: side, sigma: tuning.feather)
        var weight = [Float](repeating: 1, count: count), rho = [Float](repeating: 0, count: count)
        for i in 0..<count {
            // A replaced zone (glasses frames and their shadows) grows unconditionally.
            alpha[i] = max(core[i], ring[i] * likeness[i], replaceSoft[i])
            let x = i % side, y = i / side
            let inside = plan.x + x >= 0 && plan.x + x < width && plan.y + y >= 0 && plan.y + y < height
            // Below 1/512 the weight cannot move an 8-bit value: call it untouched.
            alpha[i] = (inside && alpha[i] >= 1 / 512) ? min(1, alpha[i]) : 0
            rho[i] = min(alpha[i], replaceSoft[i])
            weight[i] = max(0, 1 - excluded[i])
        }

        // The seam (SeamMatch): outside the masks, where the edit only
        // repeats the original once its shade is taken out, the original
        // stays — the grown ring drew a pale outline round a dressed body —
        // and where the edit shows the surroundings it loses the shade.
        var edits: [[Float]] = []
        for channel in 0..<3 {
            var e = [Float](repeating: 0, count: count)
            for i in 0..<count { e[i] = Float(edit.bytes[i * 4 + channel]) }
            edits.append(e)
        }
        let seam = SeamMatch.match(original: planes, edit: edits, thing: nearby, region: alpha, side: side, plan: plan)
        for i in 0..<count where alpha[i] > 0 && union[i] == 0 {
            alpha[i] *= 1 - seam.keep[i]
            rho[i] = min(rho[i], alpha[i])
        }
        edits = seam.edit

        var result = original
        for channel in 0..<3 {
            let o = planes[channel]
            let e = edits[channel]
            let lowO = PlaneMath.normalisedBlur(o, weight: weight, width: side, height: side, sigma: tuning.detail)
            let lowE = PlaneMath.normalisedBlur(e, weight: weight, width: side, height: side, sigma: tuning.detail)
            for i in 0..<count where alpha[i] > 0 {
                let keep = lowE[i] + (o[i] - lowO[i])
                let inner = rho[i] * e[i] + (1 - rho[i]) * keep
                let value = o[i] * (1 - alpha[i]) + alpha[i] * inner
                let at = ((plan.y + i / side) * width + plan.x + i % side) * 4 + channel
                result.bytes[at] = UInt8(min(255, max(0, value.rounded())))
            }
        }

        // Measure, don't assume: the largest change anywhere the region did not reach.
        var touched = [Bool](repeating: false, count: width * height), regionPixels = 0
        for i in 0..<count where alpha[i] > 0 {
            touched[(plan.y + i / side) * width + plan.x + i % side] = true
            regionPixels += 1
        }
        var worst = 0
        for p in 0..<(width * height) where !touched[p] {
            for c in 0..<4 { worst = max(worst, abs(Int(result.bytes[p * 4 + c]) - Int(original.bytes[p * 4 + c]))) }
        }
        let report = MaskedEditReport(regionFraction: Double(regionPixels) / Double(width * height),
                                      untouchedMaxDifference: worst)
        return (result, report)
    }
}
