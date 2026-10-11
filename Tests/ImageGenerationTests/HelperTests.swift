//
//  HelperTests.swift
//  ImageGenerationTests
//
//  Created by David Sherlock on 2026.
//
//  Everything that needs no model: prompts, seeds, cropping, recognising an
//  export, and the provenance written into every file.
//

import CoreGraphics
import Foundation
import Testing
@testable import ImageGeneration

@Suite("Prompts")
struct PromptTests {

    @Test("The no-text suffix is added, once, after trailing punctuation")
    func suffix() throws {
        #expect(PromptText.composed("a red bicycle", allowText: false) == "a red bicycle, no text, no letters, no typography")
        #expect(PromptText.composed("a red bicycle.  ", allowText: false) == "a red bicycle, no text, no letters, no typography")
        #expect(PromptText.composed("a sign that says OPEN", allowText: true) == "a sign that says OPEN")
    }

    @Test("Empty and overlong prompts are refused")
    func validation() throws {
        #expect(throws: ImageGenerationError.self) { try PromptText.validated("   \n") }
        #expect(throws: ImageGenerationError.self) { try PromptText.validated(String(repeating: "a", count: 2001)) }
        #expect(try PromptText.validated("  a fox ") == "a fox")
        #expect(try ImageGenerator.validatedPrompt(" a fox") == "a fox")
        #expect(ImageGenerator.promptSent(for: "a fox", allowText: false).hasSuffix(ImageGenerator.noTextSuffix))
    }
}

@Suite("Seeds")
struct SeedTests {

    @Test("A run counts up from its seed, wrapping at the top")
    func plan() {
        #expect(SeedPlan.seeds(start: 7, count: 4) == [7, 8, 9, 10])
        #expect(SeedPlan.seeds(start: UInt32.max, count: 2) == [UInt32.max, 0])
        #expect(SeedPlan.seeds(start: nil, count: 2, random: { 41 }) == [41, 42])
        #expect(SeedPlan.seeds(start: 1, count: 0).isEmpty)
    }
}

@Suite("Cropping and exports")
struct CropAndBundleTests {

    @Test("A wide picture is cut to its centred square; a square one is untouched")
    func crop() throws {
        let wide = try #require(Fixture.image(width: 300, height: 200))
        let square = SquareCrop.centred(wide)
        #expect(square.width == 200 && square.height == 200)
        let same = try #require(Fixture.image(width: 64, height: 64))
        #expect(SquareCrop.centred(same) === same)
    }

    @Test("An export is recognised from its metadata.json, and anything else refused")
    func identity() throws {
        let flux = try Fixture.bundle(#"{"kind":"diffusion","name":"FLUX.2-klein-4B","source":{"hf_model_id":"black-forest-labs/FLUX.2-klein-4B"}}"#)
        #expect(try BundleIdentity.model(at: flux) == .flux2Klein4B)
        let sana = try Fixture.bundle(#"{"kind":"diffusion","name":"Sana_Sprint_1.6B_1024px_diffusers","source":{"hf_model_id":"Efficient-Large-Model/Sana_Sprint_1.6B_1024px_diffusers"}}"#)
        #expect(try BundleIdentity.model(at: sana) == .sanaSprint16B)
        let small = try Fixture.bundle(#"{"kind":"diffusion","name":"Sana_Sprint_0.6B_1024px_diffusers","source":{"hf_model_id":"Efficient-Large-Model/Sana_Sprint_0.6B_1024px_diffusers"}}"#)
        #expect(throws: ImageGenerationError.unsupportedModel("Sana_Sprint_0.6B_1024px_diffusers")) { try BundleIdentity.model(at: small) }
        let segmenter = try Fixture.bundle(#"{"kind":"segmenter","name":"sam3"}"#)
        #expect(throws: ImageGenerationError.notABundle(segmenter.path)) { try BundleIdentity.model(at: segmenter) }
        let empty = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        #expect(throws: ImageGenerationError.notABundle(empty.path)) { try BundleIdentity.model(at: empty) }
    }

    @Test("Only FLUX edits; both make 1024 squares")
    func details() {
        #expect(GenerationModel.flux2Klein4B.supportsEditing)
        #expect(!GenerationModel.sanaSprint16B.supportsEditing)
        #expect(GenerationModel.allCases.allSatisfy { $0.imageSize == 1024 })
    }
}

@Suite("Provenance")
struct ProvenanceTests {

    @Test("PNG, JPEG and HEIC say AI-generated; the prompt only when asked", arguments: ["png", "jpg", "heic"])
    func marked(_ ext: String) throws {
        let picture = GeneratedImage(image: try #require(Fixture.image(width: 64, height: 64)), seed: 1,
                                     model: .flux2Klein4B, prompt: "a private prompt", promptSent: "x",
                                     edited: false, seconds: 0)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("prov-\(UUID().uuidString).\(ext)")
        defer { try? FileManager.default.removeItem(at: url) }
        try picture.write(to: url, generator: "tests 1.0")
        #expect(GeneratedImage.digitalSourceType(of: url) == ProvenanceWriter.digitalSourceType)
        let xmp = try #require(Fixture.xmp(of: url))
        #expect(xmp.contains("FLUX.2 [klein] 4B"))
        #expect(xmp.contains("tests 1.0"))
        #expect(!xmp.contains("a private prompt"), "the prompt stays out unless asked")

        try picture.write(to: url, generator: "tests 1.0", embedPrompt: true)
        #expect(try #require(Fixture.xmp(of: url)).contains("a private prompt"))
    }

    @Test("Other formats are refused before anything is written")
    func refused() throws {
        let picture = GeneratedImage(image: try #require(Fixture.image(width: 8, height: 8)), seed: 1,
                                     model: .sanaSprint16B, prompt: "p", promptSent: "p", edited: false, seconds: 0)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("x.tiff")
        #expect(throws: ImageGenerationError.self) { try picture.write(to: url, generator: "t") }
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }
}
