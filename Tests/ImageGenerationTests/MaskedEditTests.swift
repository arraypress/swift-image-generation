//
//  MaskedEditTests.swift
//  ImageGenerationTests
//
//  Created by David Sherlock on 2026.
//
//  The promises a masked edit makes, pinned without a model: an edit that
//  changes nothing changes nothing; pixels outside the region are the
//  original's, byte for byte; a recolour keeps the original's texture; a
//  replaced region takes the edit's; and an occluder's dark does not bleed
//  into the skin around it as a halo (the portrait prototype's trap).
//

import CoreGraphics
import Foundation
import Testing
@testable import ImageGeneration

/// RGBA test pictures with a known texture.
private enum Pictures {

    /// A deterministic textured picture: a mid colour plus fine noise.
    static func textured(width: Int, height: Int, base: (Int, Int, Int) = (150, 120, 100), seed: UInt64 = 1) -> [UInt8] {
        var state = seed &* 0x9E3779B97F4A7C15 | 1
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for p in 0..<(width * height) {
            state ^= state << 13; state ^= state >> 7; state ^= state << 17
            let n = Int(state % 41) - 20
            bytes[p * 4] = UInt8(clamping: base.0 + n)
            bytes[p * 4 + 1] = UInt8(clamping: base.1 + n)
            bytes[p * 4 + 2] = UInt8(clamping: base.2 + n)
        }
        return bytes
    }

    static func image(_ bytes: [UInt8], width: Int, height: Int) -> CGImage {
        PixelRaster(width: width, height: height, bytes: bytes, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!).image()!
    }

    static func raster(_ image: CGImage) -> PixelRaster {
        PixelRaster.render(image, width: image.width, height: image.height,
                           colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)!
    }

    /// A mask: 255 inside the rectangle.
    static func mask(_ name: String, width: Int, height: Int, rect: (x: Int, y: Int, w: Int, h: Int),
                     replaces: Bool = false) -> RegionMask {
        var pixels = [UInt8](repeating: 0, count: width * height)
        for y in rect.y..<(rect.y + rect.h) { for x in rect.x..<(rect.x + rect.w) { pixels[y * width + x] = 255 } }
        return RegionMask(name: name, width: width, height: height, pixels: pixels, replaces: replaces)
    }
}

@Suite("Masked edits")
struct MaskedEditTests {

    @Test("The square surrounds the mask with room, stays inside a picture it fits, and spans a short side it cannot")
    func planning() throws {
        let small = Pictures.mask("thing", width: 1000, height: 800, rect: (900, 700, 60, 60))
        let plan = try MaskedEdit.plan([small], imageWidth: 1000, imageHeight: 800)
        #expect(plan.side == 256, "a small mask still gets a 256 px square for context")
        #expect(plan.x >= 0 && plan.x + plan.side <= 1000 && plan.y >= 0 && plan.y + plan.side <= 800)
        #expect(plan.x <= 900 && plan.x + plan.side >= 960 && plan.y <= 700 && plan.y + plan.side >= 760)

        let tall = Pictures.mask("person", width: 600, height: 1200, rect: (50, 100, 500, 1000))
        let wide = try MaskedEdit.plan([tall], imageWidth: 600, imageHeight: 1200)
        #expect(wide.side > 600 && wide.side <= 1200, "wider than the picture's short side, never the long one")
        #expect(wide.x < 0 && wide.x + wide.side > 600, "centred across the short side")

        #expect(throws: ImageGenerationError.self) {
            try MaskedEdit.plan([Pictures.mask("none", width: 10, height: 10, rect: (0, 0, 0, 0))], imageWidth: 10, imageHeight: 10)
        }
    }

    @Test("A mask a pixel off is resized to the picture")
    func fitting() {
        let mask = RegionMask(name: "x", width: 9, height: 10, pixels: [UInt8](repeating: 255, count: 90))
        #expect(MaskedComposite.fitted(mask, width: 10, height: 10).count == 100)
        #expect(MaskedComposite.fitted(mask, width: 10, height: 10).allSatisfy { $0 == 255 })
    }

    @Test("An edit that changes nothing changes nothing; outside the region every byte is the original's")
    func identity() throws {
        let (w, h) = (400, 300)
        let original = Pictures.image(Pictures.textured(width: w, height: h), width: w, height: h)
        let mask = Pictures.mask("thing", width: w, height: h, rect: (150, 100, 80, 80))
        let plan = try MaskedEdit.plan([mask], imageWidth: w, imageHeight: h)
        let square = try MaskedEdit.source(original, plan: plan, size: plan.side)
        let (result, report) = try MaskedEdit.composite(original: original, edited: square, masks: [mask], plan: plan)
        #expect(report.untouchedMaxDifference == 0)
        #expect(report.regionFraction > 0 && report.regionFraction < 0.2)
        let a = Pictures.raster(original).bytes, b = Pictures.raster(result).bytes
        let worst = zip(a, b).map { abs(Int($0) - Int($1)) }.max() ?? 0
        #expect(worst <= 1, "inside too: an unchanged edit leaves the picture as it was (worst \(worst))")
    }

    @Test("A recolour keeps the original's texture inside the mask and touches nothing outside")
    func recolourKeepsDetail() throws {
        let (w, h) = (400, 300)
        let originalBytes = Pictures.textured(width: w, height: h)
        let original = Pictures.image(originalBytes, width: w, height: h)
        let mask = Pictures.mask("jacket", width: w, height: h, rect: (120, 80, 160, 140))
        let plan = try MaskedEdit.plan([mask], imageWidth: w, imageHeight: h)
        // The "edit": the same square, recoloured red AND smoothed (an edit model's habit).
        let side = plan.side
        var edited = [UInt8](repeating: 255, count: side * side * 4)
        for p in 0..<(side * side) { edited[p * 4] = 210; edited[p * 4 + 1] = 40; edited[p * 4 + 2] = 40 }
        let (result, report) = try MaskedEdit.composite(original: original, edited: Pictures.image(edited, width: side, height: side),
                                                        masks: [mask], plan: plan)
        #expect(report.untouchedMaxDifference == 0)
        let out = Pictures.raster(result).bytes
        // Deep inside the mask: red on average, with the original's noise kept.
        var reds: [Int] = [], diffs: [Int] = []
        for y in 120..<180 { for x in 160..<240 {
            let p = (y * w + x) * 4
            reds.append(Int(out[p]))
            diffs.append(Int(out[p + 1]) - Int(originalBytes[p + 1]))   // green: original noise + a constant shift
        } }
        let meanRed = Double(reds.reduce(0, +)) / Double(reds.count)
        #expect(meanRed > 190, "recoloured (mean red \(meanRed))")
        let meanShift = Double(diffs.reduce(0, +)) / Double(diffs.count)
        let spread = diffs.map { abs(Double($0) - meanShift) }.max() ?? 99
        #expect(spread < 6, "the change is a smooth shift; the texture is the original's (spread \(spread))")
    }

    @Test("The grown ring takes the object's missed fringe but not the background beside it (no colour glow)")
    func noGlowOntoTheBackground() throws {
        let (w, h) = (400, 400)
        // A pale wall with a blue object; the mask misses the object's outer 3 px.
        var bytes = Pictures.textured(width: w, height: h, base: (225, 225, 220))
        for y in 120..<280 { for x in 120..<280 {
            let p = (y * w + x) * 4; bytes[p] = 40; bytes[p + 1] = 60; bytes[p + 2] = 120
        } }
        let original = Pictures.image(bytes, width: w, height: h)
        let mask = Pictures.mask("object", width: w, height: h, rect: (123, 123, 154, 154))
        let plan = try MaskedEdit.plan([mask], imageWidth: w, imageHeight: h)
        // The edit: the object red, the wall a little pinker too (an edit model's colour cast).
        let side = plan.side
        var edited = [UInt8](repeating: 255, count: side * side * 4)
        for y in 0..<side { for x in 0..<side {
            let ix = plan.x + x, iy = plan.y + y, p = (y * side + x) * 4
            let inObject = ix >= 120 && ix < 280 && iy >= 120 && iy < 280
            edited[p] = inObject ? 220 : 240; edited[p + 1] = inObject ? 40 : 205; edited[p + 2] = inObject ? 40 : 205
        } }
        let (result, _) = try MaskedEdit.composite(original: original, edited: Pictures.image(edited, width: side, height: side),
                                                   masks: [mask], plan: plan)
        let out = Pictures.raster(result).bytes
        let fringe = (200 * w + 121) * 4          // object, outside the mask
        #expect(out[fringe] > 150, "the missed fringe is recoloured: red \(out[fringe])")
        for x in [112, 116] {                       // wall, a few px outside the object
            let p = (200 * w + x) * 4
            let shift = abs(Int(out[p + 1]) - Int(bytes[p + 1]))
            #expect(shift <= 6, "no glow on the wall at x=\(x): green moved \(shift)")
        }
    }

    @Test("The edit's overall shade draws no outline round the region (the dressing halo)")
    func noPaleOutline() throws {
        let (w, h) = (300, 300)
        let wall = (230, 228, 222), white = (246, 246, 248)
        // A grey wall (fine grain) and a white t-shirt; the mask misses the shirt's outer 2 px.
        var bytes = Pictures.textured(width: w, height: h, base: wall, seed: 3).enumerated().map { i, v -> UInt8 in
            i % 4 == 3 ? 255 : UInt8(clamping: Int(([wall.0, wall.1, wall.2][i % 4])) + (Int(v) - [wall.0, wall.1, wall.2][i % 4]) / 6)
        }
        for y in 80..<220 { for x in 100..<200 {
            let p = (y * w + x) * 4; bytes[p] = UInt8(white.0); bytes[p + 1] = UInt8(white.1); bytes[p + 2] = UInt8(white.2)
        } }
        let original = Pictures.image(bytes, width: w, height: h)
        let mask = Pictures.mask("tshirt", width: w, height: h, rect: (102, 82, 96, 136), replaces: true)
        let plan = try MaskedEdit.plan([mask], imageWidth: w, imageHeight: h)
        // The edit: a narrower red top, and the wall — even where the shirt was — paler and
        // cooler everywhere (+6, +8, +10: FLUX's shade on the dressing fixtures).
        let side = plan.side
        var edited = [UInt8](repeating: 255, count: side * side * 4)
        for y in 0..<side { for x in 0..<side {
            let ix = plan.x + x, iy = plan.y + y, p = (y * side + x) * 4
            let top = ix >= 112 && ix < 188 && iy >= 90 && iy < 210
            edited[p] = UInt8(top ? 200 : wall.0 + 6); edited[p + 1] = UInt8(top ? 40 : wall.1 + 8)
            edited[p + 2] = UInt8(top ? 60 : wall.2 + 10)
        } }
        let (result, report) = try MaskedEdit.composite(original: original, edited: Pictures.image(edited, width: side, height: side),
                                                        masks: [mask], plan: plan)
        #expect(report.untouchedMaxDifference == 0)
        let out = Pictures.raster(result).bytes
        func blue(_ x: Int, _ y: Int) -> Int { Int(out[(y * w + x) * 4 + 2]) }
        // The wall just outside the shirt: the original's own pixels, not the paler edit.
        for x in [97, 99, 200, 202] {
            let p = (150 * w + x) * 4
            let moved = (0..<3).map { abs(Int(out[p + $0]) - Int(bytes[p + $0])) }.max() ?? 0
            #expect(moved <= 2, "no pale outline at x=\(x): moved \(moved)")
        }
        // The shirt's missed fringe still goes: wall-coloured now, not white.
        #expect(abs(blue(101, 150) - wall.2) <= 6, "the fringe is replaced: blue \(blue(101, 150))")
        // The wall the edit painted where the shirt was: shade taken out.
        #expect(abs(blue(106, 150) - wall.2) <= 3, "painted wall matches the wall: blue \(blue(106, 150))")
        // The new top is the edit's, untouched by the shade.
        let centre = (150 * w + 150) * 4
        #expect(out[centre] == 200 && out[centre + 1] == 40 && out[centre + 2] == 60, "the top is not recoloured")
    }

    @Test("A replacing mask takes the edit's own pixels")
    func replaceTakesTheEdit() throws {
        let (w, h) = (400, 300)
        let original = Pictures.image(Pictures.textured(width: w, height: h), width: w, height: h)
        let mask = Pictures.mask("object", width: w, height: h, rect: (150, 100, 100, 100), replaces: true)
        let plan = try MaskedEdit.plan([mask], imageWidth: w, imageHeight: h)
        let side = plan.side
        var edited = [UInt8](repeating: 255, count: side * side * 4)
        for p in 0..<(side * side) { edited[p * 4] = 30; edited[p * 4 + 1] = 200; edited[p * 4 + 2] = 90 }
        let (result, report) = try MaskedEdit.composite(original: original, edited: Pictures.image(edited, width: side, height: side),
                                                        masks: [mask], plan: plan)
        #expect(report.untouchedMaxDifference == 0)
        let out = Pictures.raster(result).bytes
        let p = (150 * w + 200) * 4
        #expect(abs(Int(out[p]) - 30) <= 2 && abs(Int(out[p + 1]) - 200) <= 2, "the centre is the edit, noise and all replaced")
    }

    @Test("An occluder's dark does not bleed into the skin around it (the halo trap)")
    func noHaloAroundAnOccluder() throws {
        let (w, h) = (400, 400)
        // Skin, with a thick dark ring (a glasses frame) in it.
        var bytes = Pictures.textured(width: w, height: h, base: (200, 160, 140))
        var ring = [UInt8](repeating: 0, count: w * h)
        for y in 0..<h { for x in 0..<w {
            let d = (Double(x - 200) * Double(x - 200) + Double(y - 200) * Double(y - 200)).squareRoot()
            if d > 60 && d < 72 { let p = (y * w + x) * 4; bytes[p] = 15; bytes[p + 1] = 15; bytes[p + 2] = 15; ring[y * w + x] = 255 }
        } }
        let original = Pictures.image(bytes, width: w, height: h)
        let face = Pictures.mask("face", width: w, height: h, rect: (90, 90, 220, 220))
        let frames = RegionMask(name: "glasses frame", width: w, height: h, pixels: ring, replaces: true)
        let plan = try MaskedEdit.plan([face, frames], imageWidth: w, imageHeight: h)
        // The edit: the same skin with no ring.
        let side = plan.side
        var edited = [UInt8](repeating: 255, count: side * side * 4)
        for p in 0..<(side * side) { edited[p * 4] = 200; edited[p * 4 + 1] = 160; edited[p * 4 + 2] = 140 }
        let (result, report) = try MaskedEdit.composite(original: original, edited: Pictures.image(edited, width: side, height: side),
                                                        masks: [face, frames], plan: plan)
        #expect(report.untouchedMaxDifference == 0)
        let out = Pictures.raster(result).bytes
        // Skin just inside and just outside where the ring was: no dark halo.
        for (x, y) in [(200, 200 - 40), (200, 200 + 95), (200 - 95, 200), (200 + 40, 200)] {
            let p = (y * w + x) * 4
            #expect(Int(out[p]) > 170, "no halo at (\(x),\(y)): red \(out[p])")
        }
        let onRing = (200 * w + 266) * 4
        #expect(Int(out[onRing]) > 170, "the frame itself is replaced by skin: red \(out[onRing])")
    }

    @Test("Each model's step range")
    func stepRanges() {
        #expect(GenerationModel.sanaSprint16B.stepRange == 1...4)
        #expect(GenerationModel.flux2Klein4B.stepRange.contains(4))
        #expect(!GenerationModel.flux2Klein4B.stepRange.contains(0))
    }
}
