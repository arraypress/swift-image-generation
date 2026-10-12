//
//  FaceFixTests.swift
//  ImageGenerationTests
//
//  Created by David Sherlock on 2026.
//
//  The face fix's geometry, pinned without a model: which faces qualify,
//  that the redrawn square holds the face with room around it and stays
//  inside the picture, and that the oval which goes back covers the face
//  and nothing far from it.
//

import CoreGraphics
import Foundation
import Testing
@testable import ImageGeneration

@Suite("Face fix")
struct FaceFixTests {

    private func face(_ x: Double, _ y: Double, _ side: Double, confidence: Float = 0.8) -> DetectedFace {
        DetectedFace(box: CGRect(x: x, y: y, width: side, height: side), confidence: confidence, quality: 0.3)
    }

    @Test("Small, confident faces qualify; large or doubtful ones do not")
    func qualifies() {
        let options = FaceFixOptions.standard
        #expect(FacePlan.needsFix(face(480, 337, 71), imageWidth: 1024, imageHeight: 1024, options: options))
        // Measured: 119 px needed it; a fine 180 px face came back as someone else.
        #expect(FacePlan.needsFix(face(0, 0, 119), imageWidth: 1024, imageHeight: 1024, options: options))
        #expect(!FacePlan.needsFix(face(0, 0, 180), imageWidth: 1024, imageHeight: 1024, options: options))
        #expect(!FacePlan.needsFix(face(480, 337, 71, confidence: 0.3), imageWidth: 1024, imageHeight: 1024, options: options))
        #expect(!FacePlan.needsFix(face(10, 10, 4), imageWidth: 1024, imageHeight: 1024, options: options))
    }

    @Test("The square is context × the face, centred on it, inside the picture")
    func square() {
        let box = CGRect(x: 480, y: 337, width: 71, height: 71)
        let plan = FacePlan.plan(for: box, imageWidth: 1024, imageHeight: 1024, context: 2.5)
        #expect(plan.side == 178)   // 2.5 here; the default is 3.5
        #expect(plan.rect.contains(box))
        #expect(abs(plan.rect.midX - box.midX) <= 1 && abs(plan.rect.midY - box.midY) <= 1)
        // A face at the corner: the square slides inside rather than running off.
        let corner = FacePlan.plan(for: CGRect(x: 2, y: 3, width: 60, height: 60), imageWidth: 1024, imageHeight: 768, context: 3)
        #expect(corner.x == 0 && corner.y == 0 && corner.side == 180)
        // A tiny face still gets a square the model can work with.
        #expect(FacePlan.plan(for: CGRect(x: 500, y: 500, width: 10, height: 10), imageWidth: 1024, imageHeight: 1024,
                              context: 2.5).side == 64)
    }

    @Test("The oval covers the face and reaches the forehead, nothing far away")
    func oval() {
        let box = CGRect(x: 100, y: 100, width: 60, height: 60)
        let mask = FacePlan.mask(for: box, imageWidth: 300, imageHeight: 300)
        #expect(mask.replaces)
        func at(_ x: Int, _ y: Int) -> UInt8 { mask.pixels[y * 300 + x] }
        #expect(at(130, 130) == 255)          // the centre
        #expect(at(130, 95) == 255)           // above the box: the forehead
        #expect(at(130, 170) == 0)            // well below the chin
        #expect(at(60, 130) == 0 && at(200, 130) == 0)
        #expect(at(0, 0) == 0)
    }

    @Test("The instruction names who, not the whole scene, and says what to keep")
    func instruction() throws {
        let text = FacePlan.instruction(for: "a woman, wearing a coat, in a lantern-lit alley")
        #expect(text.contains("face of a woman"))
        #expect(!text.contains("alley") && !text.contains("coat,"))
        #expect(text.contains("Keep the framing"))
        #expect(FacePlan.subject(of: String(repeating: "a", count: 3000)).isEmpty)
        _ = try PromptText.validated(FacePlan.instruction(for: String(repeating: "a", count: 3000)))
        #expect(FacePlan.instruction(for: "a man", withReferences: true).contains("same person as in the other pictures"))
        #expect(!FacePlan.instruction(for: "a man").contains("other pictures"))
    }

    @Test("A picture with no face comes back untouched, with no report")
    func noFaces() throws {
        let side = 64
        let bytes = [UInt8](repeating: 200, count: side * side * 4)
        let provider = try #require(CGDataProvider(data: Data(bytes) as CFData))
        let image = try #require(CGImage(width: side, height: side, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: side * 4,
                                         space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                         bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                         provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent))
        #expect(try ImageGenerator.faces(in: image).isEmpty)
    }
}
