//
//  DressingTests.swift
//  ImageGenerationTests
//
//  Created by David Sherlock on 2026.
//
//  The pieces of dressing someone that need no model: other words for a
//  mask, which word wins, what a garment picture is, where it goes on a
//  person, its colour in words, and framing a reference around its subject.
//  The numbers in the cases are the SAM 3 scores measured on generated
//  fashion photos (2026-10-14).
//

import CoreGraphics
import Foundation
import Testing
@testable import ImageGeneration

@Suite("Mask words")
struct RegionWordTests {

    @Test("A name is tried first, then the words people use for the same thing")
    func candidates() {
        #expect(RegionMask.candidates(for: "t-shirt") == ["t-shirt", "tshirt", "top", "shirt", "tee", "blouse"])
        #expect(RegionMask.candidates(for: "Jacket") == ["Jacket", "blazer", "coat", "suit jacket"])
        #expect(RegionMask.candidates(for: "trousers").prefix(3) == ["trousers", "pants", "jeans"])
        #expect(RegionMask.candidates(for: "jumper").contains("sweater"))
        #expect(RegionMask.candidates(for: "sneaker").contains("shoes"))
        #expect(RegionMask.candidates(for: "dress").contains("skirt"))
        #expect(RegionMask.candidates(for: "cap").contains("hat"))
        // A word in no group stands alone; spacing is tidied, case kept.
        #expect(RegionMask.candidates(for: "  glasses frame ") == ["glasses frame"])
        #expect(RegionMask.candidates(for: "") == [])
        // Each word once, even where groups overlap ("top" is in two).
        let top = RegionMask.candidates(for: "top")
        #expect(Set(top).count == top.count)
        #expect(top.contains("sweater") && top.contains("tshirt"))
    }

    @Test("The name wins when it passes; else the best other that does; never one below the floor")
    func choose() {
        // A navy blazer asked for as "jacket": 0.40 / 0.97.
        #expect(RegionMask.chooseWord([("jacket", 0.40), ("blazer", 0.97), ("coat", 0.70)], minimum: 0.6) == "blazer")
        // The name passes: kept even though another word scores higher.
        #expect(RegionMask.chooseWord([("top", 0.92), ("tshirt", 0.99)], minimum: 0.6) == "top")
        // Nothing passes: nothing is picked.
        #expect(RegionMask.chooseWord([("jacket", 0.40), ("blazer", 0.59)], minimum: 0.6) == nil)
        #expect(RegionMask.chooseWord([], minimum: 0.6) == nil)
    }
}

@Suite("Garments")
struct GarmentTests {

    /// The class-word scores measured on the six generated garment pictures.
    static let measured: [(String, [GarmentKind: Double], GarmentKind)] = [
        ("mustard jacket", [.outerwear: 0.97, .top: 0.79, .dress: 0.07, .trousers: 0.01], .outerwear),
        ("striped top on a mannequin", [.top: 0.98, .dress: 0.92, .outerwear: 0.02], .top),
        ("green trousers", [.trousers: 0.98, .skirt: 0.69, .shorts: 0.17, .dress: 0.06], .trousers),
        ("sneakers", [.shoes: 0.93], .shoes),
        ("dress on a mannequin", [.dress: 0.98, .top: 0.13], .dress),
        ("dress laid flat", [.dress: 0.99, .top: 0.80], .dress),
    ]

    @Test("A garment picture is the kind its class word scores best, a near-tie going to the particular kind")
    func classify() {
        for (what, scores, kind) in Self.measured {
            let found = GarmentKind.classify(scores, minimum: 0.6)
            #expect(found == kind, Comment(rawValue: what))
        }
        #expect(GarmentKind.classify([.top: 0.98, .dress: 0.97], minimum: 0.6) == .dress)
        #expect(GarmentKind.classify([.top: 0.5, .dress: 0.4], minimum: 0.6) == nil)
    }

    @Test("Words name kinds")
    func words() {
        #expect(GarmentKind(word: "T-shirt") == .top)
        #expect(GarmentKind(word: "blazer") == .outerwear)
        #expect(GarmentKind(word: "jeans") == .trousers)
        #expect(GarmentKind(word: "sneakers") == .shoes)
        #expect(GarmentKind(word: "dress") == .dress)
        #expect(GarmentKind(word: "unicorn") == nil)
    }

    @Test("Where a garment goes: the arm only with sleeves on the upper body")
    func regions() {
        let top = GarmentKind.top.regions(sleeved: true)
        #expect(top.contains { $0.words.contains("tshirt") })
        #expect(top.last?.words.first == "arm")
        #expect(!GarmentKind.top.regions(sleeved: false).contains { $0.words.contains("arm") })
        #expect(!GarmentKind.trousers.regions(sleeved: true).contains { $0.words.contains("arm") })
        #expect(GarmentKind.trousers.regions(sleeved: false).allSatisfy { $0.required })
        #expect(GarmentKind.shoes.regions(sleeved: false).contains { $0.words.contains("feet") })
    }

    @Test("The instruction speaks of the two sides and says what stays")
    func instruction() {
        let text = GarmentKind.outerwear.instruction(longSleeves: true)
        #expect(text.hasPrefix("Dress the person on the left in the long-sleeved jacket shown on the right"))
        #expect(text.contains("with exactly its colours, pattern and cut, its sleeves down to the wrists."))
        #expect(text.contains("Keep their face, hair, pose, trousers and the background exactly as they are."))
        #expect(GarmentKind.top.instruction(noun: "sweater").contains("in the sweater shown on the right"))
        #expect(GarmentKind.top.instruction(colour: "navy").contains("in the navy top"))
        #expect(!text.contains("stripes"))
    }

    @Test("A striped garment is named striped, with its stripes asked for as wide as shown")
    func stripedInstruction() {
        // The wording measured on the striped top (white 23% → 32% of the garment against 35%).
        let text = GarmentKind.top.instruction(colour: "red and white", longSleeves: true, striped: true)
        #expect(text.hasPrefix("Dress the person on the left in the red and white striped long-sleeved top shown on the right, "
                               + "in place of what they are wearing there: the same top, with exactly its colours, pattern and cut: "
                               + "its stripes as many and as wide as shown, its sleeves down to the wrists. Keep"))
    }

    @Test("Horizontal stripes are told from prints and plain cloth by how the lightness repeats")
    func stripes() {
        let (w, h) = (200, 240)
        func garment(_ value: (Int, Int) -> Double) -> [Double] {
            var out = [Double](repeating: .nan, count: w * h)
            for y in 20..<220 { for x in 30..<170 { out[y * w + x] = value(x, y) } }
            return out
        }
        // Soft-edged bands as a camera sees them, every 30 px; vertical ones are not read.
        let bands = garment { _, y in 72 + 20 * tanh(3 * cos(2 * Double.pi * Double(y) / 30)) }
        let pinstripe = garment { x, _ in 60 + 30 * tanh(3 * cos(2 * Double.pi * Double(x) / 16)) }
        // A plain garment with soft folds, and a large print whose leaves do not repeat.
        let plain = garment { x, y in 60 + 4 * sin(Double(x + y) / 25) }
        let leaves = [(52, 40, 22), (120, 70, 30), (75, 120, 26), (140, 150, 18), (60, 190, 28), (125, 205, 15)]
        let blotches = garment { x, y in
            leaves.contains { (x - $0.0) * (x - $0.0) + (y - $0.1) * (y - $0.1) < $0.2 * $0.2 } ? 40 : 90
        }
        #expect(StripeReader.regularity(bands, width: w, height: h) >= StripeReader.striped)
        #expect(StripeReader.regularity(pinstripe, width: w, height: h) < StripeReader.striped)
        #expect(StripeReader.regularity(plain, width: w, height: h) < StripeReader.striped)
        #expect(StripeReader.regularity(blotches, width: w, height: h) < StripeReader.striped)
    }

    @Test("Long sleeves reach most of the way down the garment")
    func sleeves() {
        // Measured: the striped top's sleeves end at its hem (250…980, sleeves to 981).
        #expect(GarmentKind.longSleeves(garmentTop: 250, garmentBottom: 980, sleeveBottom: 981))
        #expect(GarmentKind.longSleeves(garmentTop: 93, garmentBottom: 936, sleeveBottom: 936))
        #expect(!GarmentKind.longSleeves(garmentTop: 100, garmentBottom: 900, sleeveBottom: 360))
    }
}

@Suite("Colour words")
struct ColourNameTests {

    static func lab(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> ColourNames.Lab { ColourNames.lab(r, g, b) }

    @Test("Neutrals are named among neutrals, hues among hues")
    func names() {
        #expect(ColourNames.name(Self.lab(236, 236, 234)) == "white")      // a white stripe, never "cream"
        #expect(ColourNames.name(Self.lab(200, 25, 35)) == "red")
        #expect(ColourNames.name(ColourNames.Lab(l: 33.4, a: -4.7, b: -0.1)) == "bottle green")   // the trousers, measured
        #expect(ColourNames.name(Self.lab(20, 20, 20)) == "black")
        #expect(ColourNames.name(Self.lab(25, 35, 75)) == "navy")
    }

    @Test("Two main colours are both named; a small one is not")
    func describe() {
        let stripes = Array(repeating: Self.lab(200, 25, 35), count: 60) + Array(repeating: Self.lab(250, 250, 250), count: 40)
        #expect(ColourNames.describe(stripes) == "red and white")
        let buttons = Array(repeating: Self.lab(215, 165, 40), count: 90) + Array(repeating: Self.lab(75, 45, 30), count: 10)
        #expect(ColourNames.describe(buttons) == "mustard yellow")
        #expect(ColourNames.describe([]) == nil)
    }
}

@Suite("Reference framing")
struct ReferenceFrameTests {

    /// A white picture with a red square of `side` at (x, y).
    static func product(width: Int = 200, height: Int = 200, x: Int, y: Int, side: Int,
                        border: (UInt8, UInt8, UInt8)? = nil) -> (PixelRaster, [UInt8]) {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        var mask = [UInt8](repeating: 0, count: width * height)
        for py in 0..<height {
            for px in 0..<width {
                let i = py * width + px
                if px >= x, px < x + side, py >= y, py < y + side {
                    bytes[i * 4] = 200; bytes[i * 4 + 1] = 25; bytes[i * 4 + 2] = 35; mask[i] = 255
                } else if let border, (px + py) % 2 == 0 {
                    bytes[i * 4] = border.0; bytes[i * 4 + 1] = border.1; bytes[i * 4 + 2] = border.2
                }
            }
        }
        return (PixelRaster(width: width, height: height, bytes: bytes, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!), mask)
    }

    @Test("The subject comes out centred on white with its padding")
    func onWhite() throws {
        let (raster, mask) = Self.product(x: 20, y: 120, side: 50)
        let framed = try #require(ReferenceFrame.onWhite(raster, mask: mask, padding: 0.1))
        #expect(framed.width == 60 && framed.height == 60)
        // Centre is red, corners white.
        let centre = (30 * 60 + 30) * 4, corner = 0
        #expect(framed.bytes[centre] == 200 && framed.bytes[centre + 1] == 25)
        #expect(framed.bytes[corner] == 255 && framed.bytes[corner + 2] == 255)
        #expect(ReferenceFrame.onWhite(raster, mask: [UInt8](repeating: 0, count: 200 * 200), padding: 0.1) == nil)
    }

    @Test("Only a plain background is framed, and only when the subject leaves room")
    func gate() throws {
        let (plain, mask) = Self.product(x: 50, y: 50, side: 80)
        #expect(ReferenceFrame.borderSpread(plain) < 1)
        let box = try #require(ReferenceFrame.bounds(mask, width: 200, height: 200))
        #expect(box.x == 50 && box.width == 80)
        #expect(ReferenceFrame.worthFraming(borderSpread: 0.5, box: box, width: 200, height: 200))
        // A busy border (a checkerboard of black on white) is not plain.
        let (busy, _) = Self.product(x: 50, y: 50, side: 80, border: (0, 0, 0))
        #expect(ReferenceFrame.borderSpread(busy) > ReferenceFrame.plainBorderLimit)
        // A subject spanning the picture is left alone.
        #expect(!ReferenceFrame.worthFraming(borderSpread: 0.5, box: (0, 10, 195, 100), width: 200, height: 200))
    }

    @Test("A busy picture comes back unchanged with the reason")
    func busyUnchanged() throws {
        let (busy, mask) = Self.product(x: 50, y: 50, side: 80, border: (0, 0, 0))
        let image = try #require(busy.image())
        let framed = try ReferenceFraming.frame(image, mask: RegionMask(name: "thing", width: 200, height: 200, pixels: mask))
        #expect(!framed.framed && framed.reason == "busy background")
        let (plain, plainMask) = Self.product(x: 50, y: 50, side: 80)
        let done = try ReferenceFraming.frame(try #require(plain.image()),
                                              mask: RegionMask(name: "thing", width: 200, height: 200, pixels: plainMask))
        #expect(done.framed && done.image.width == 86 && done.subjectSpan == 0.4)
    }
}
