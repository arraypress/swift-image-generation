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
        #expect(ImageGenerator.seeds(start: 7, count: 3) == [7, 8, 9])
        #expect(ImageGenerator.seeds(start: nil, count: 2).count == 2)
    }
}

@Suite("Cropping and exports")
struct CropAndBundleTests {

    @Test("A picture is trimmed around its centre to a shape; a matching one is untouched")
    func crop() throws {
        let wide = try #require(Fixture.image(width: 300, height: 200))
        let square = AspectMath.centred(wide, width: 1024, height: 1024)
        #expect(square.width == 200 && square.height == 200)
        let same = try #require(Fixture.image(width: 64, height: 64))
        #expect(AspectMath.centred(same, width: 1024, height: 1024) === same)
        // A 4:3 phone photo fits 4:3 exactly; to 1:1 it loses a quarter.
        let phone = try #require(Fixture.image(width: 400, height: 300))
        #expect(AspectMath.centred(phone, width: 1152, height: 864) === phone)
        #expect(AspectMath.trimmed(width: 400, height: 300, targetWidth: 1152, targetHeight: 864) == 0)
        #expect(abs(AspectMath.trimmed(width: 400, height: 300, targetWidth: 1024, targetHeight: 1024) - 0.25) < 1e-9)
    }

    @Test("The nearest shape goes by the ratio's logarithm, among the model's shapes")
    func nearest() {
        #expect(ImageAspect.nearest(width: 4032, height: 3024) == .classic)
        #expect(ImageAspect.nearest(width: 3024, height: 4032) == .classicTall)
        #expect(ImageAspect.nearest(width: 6000, height: 4000) == .photo)
        #expect(ImageAspect.nearest(width: 1080, height: 1920) == .vertical)
        #expect(ImageAspect.nearest(width: 1920, height: 1080) == .landscape)
        #expect(ImageAspect.nearest(width: 1000, height: 1010) == .square)
        // SANA has four shapes: a 4:3 photo goes to the nearest of those (16:9, by the log ratio).
        #expect(ImageAspect.nearest(width: 4032, height: 3024, among: GenerationModel.sanaSprint16B.aspects) == .landscape)
    }

    @Test("An export is recognised from its metadata.json, and anything else refused")
    func identity() throws {
        let flux = try Fixture.bundle(#"{"kind":"diffusion","name":"FLUX.2-klein-4B","source":{"hf_model_id":"black-forest-labs/FLUX.2-klein-4B"}}"#)
        #expect(try BundleIdentity.model(at: flux) == .flux2Klein4B)
        let sana = try Fixture.bundle(#"{"kind":"diffusion","name":"Sana_Sprint_1.6B_1024px_diffusers","source":{"hf_model_id":"Efficient-Large-Model/Sana_Sprint_1.6B_1024px_diffusers"}}"#)
        #expect(try BundleIdentity.model(at: sana) == .sanaSprint16B)
        // 9B is recognised from its own metadata — no renamed copy needed.
        let nine = try Fixture.bundle(#"{"kind":"diffusion","name":"FLUX.2-klein-9B","source":{"hf_model_id":"black-forest-labs/FLUX.2-klein-9B"}}"#)
        #expect(try BundleIdentity.model(at: nine) == .flux2Klein9B)
        // FLUX.3's two exports share a checkpoint; the recorded compression tells them apart.
        let flux3 = #""kind":"diffusion","name":"flux-3-image-klein","source":{"hf_model_id":"black-forest-labs/flux-3-image-klein"}"#
        #expect(try BundleIdentity.model(at: Fixture.bundle("{\(flux3),\"compression\":\"4bit\"}")) == .flux3Klein)
        #expect(try BundleIdentity.model(at: Fixture.bundle("{\(flux3),\"compression\":\"none\"}")) == .flux3KleinFull)
        // What the exporter really writes for the bfloat16 export: no compression at all.
        #expect(try BundleIdentity.model(at: Fixture.bundle("{\(flux3)}")) == .flux3KleinFull)
        #expect(try BundleIdentity.model(at: Fixture.bundle("{\(flux3),\"compression\":null}")) == .flux3KleinFull)
        #expect(throws: ImageGenerationError.unsupportedModel("flux-3-image-klein")) {
            try BundleIdentity.model(at: Fixture.bundle("{\(flux3),\"compression\":\"8bit\"}"))
        }
        let small = try Fixture.bundle(#"{"kind":"diffusion","name":"Sana_Sprint_0.6B_1024px_diffusers","source":{"hf_model_id":"Efficient-Large-Model/Sana_Sprint_0.6B_1024px_diffusers"}}"#)
        #expect(throws: ImageGenerationError.unsupportedModel("Sana_Sprint_0.6B_1024px_diffusers")) { try BundleIdentity.model(at: small) }
        let segmenter = try Fixture.bundle(#"{"kind":"segmenter","name":"sam3"}"#)
        #expect(throws: ImageGenerationError.notABundle(segmenter.path)) { try BundleIdentity.model(at: segmenter) }
        let empty = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        #expect(throws: ImageGenerationError.notABundle(empty.path)) { try BundleIdentity.model(at: empty) }
    }

    @Test("Only FLUX 4B edits; 9B and FLUX.3 are square-only and non-commercial; 9B loads parts one at a time under 48 GB")
    func details() {
        #expect(GenerationModel.flux2Klein4B.supportsEditing)
        #expect(!GenerationModel.sanaSprint16B.supportsEditing)
        #expect(!GenerationModel.flux2Klein9B.supportsEditing)
        #expect(GenerationModel.flux2Klein4B.aspects == [.square, .landscape, .vertical, .portrait, .classic, .photo])
        #expect(GenerationModel.flux2Klein4B.editAspects == [.square, .landscape, .vertical, .classic, .classicTall, .photo, .photoTall])
        #expect(GenerationModel.sanaSprint16B.editAspects.isEmpty && GenerationModel.flux2Klein9B.editAspects.isEmpty)
        #expect(ImageAspect.allCases.count == 8)
        #expect(GenerationModel.sanaSprint16B.aspects == [.square, .landscape, .vertical, .portrait])
        #expect(GenerationModel.flux2Klein9B.aspects == [.square])
        #expect(GenerationModel.flux3Klein.aspects == [.square] && GenerationModel.flux3KleinFull.aspects == [.square])
        #expect(!GenerationModel.flux3Klein.supportsEditing && GenerationModel.flux3KleinFull.editAspects.isEmpty)
        #expect(GenerationModel.allCases.filter(\.isNonCommercial) == [.flux2Klein9B, .flux3Klein, .flux3KleinFull])
        let gb: UInt64 = 1_073_741_824
        #expect(GenerationModel.flux2Klein9B.loadsPartsOneAtATime(physicalMemory: 36 * gb))
        #expect(!GenerationModel.flux2Klein9B.loadsPartsOneAtATime(physicalMemory: 64 * gb))
        #expect(GenerationModel.flux2Klein4B.loadsPartsOneAtATime(physicalMemory: 16 * gb))
        #expect(!GenerationModel.flux2Klein4B.loadsPartsOneAtATime(physicalMemory: 24 * gb))
        #expect(GenerationModel.sanaSprint16B.loadsPartsOneAtATime(physicalMemory: 8 * gb))
        #expect(!GenerationModel.sanaSprint16B.loadsPartsOneAtATime(physicalMemory: 36 * gb))
        #expect(ImageGenerationError.unsupportedModel("x").errorDescription?.contains("FLUX.2 [klein] 9B") == true)
    }

    @Test("Aspect sizes suit both models: multiples of 32, 16:9 within 2 %")
    func aspects() {
        #expect(ImageAspect.square.size == (1024, 1024) && ImageAspect.square.subfolder == nil)
        let wide = ImageAspect.landscape.size
        #expect(wide.width % 32 == 0 && wide.height % 32 == 0)
        #expect(abs(Double(wide.width) / Double(wide.height) - 16.0 / 9.0) / (16.0 / 9.0) < 0.02)
        #expect(ImageAspect(rawValue: "16:9") == .landscape)
        #expect(ImageAspect.landscape.subfolder == "aspect-16x9")
        #expect(ImageAspect(rawValue: "9:16") == .vertical)
        #expect(ImageAspect(rawValue: "4:5") == .portrait)
        #expect(ImageAspect.vertical.size == (768, 1344) && ImageAspect.portrait.size == (896, 1120))
        #expect(ImageAspect.vertical.subfolder == "aspect-9x16" && ImageAspect.portrait.subfolder == "aspect-4x5")
        #expect(ImageAspect.classic.size == (1152, 864) && ImageAspect.photo.size == (1248, 832))
        #expect(ImageAspect.classic.subfolder == nil, "SANA has no 4:3")
        #expect(ImageAspect.classic.shapeFolder == "shapes/4x3" && ImageAspect.square.shapeFolder == "shapes/1x1")
        #expect(ImageAspect.photoTall.shapeFolder == "shapes/2x3" && ImageAspect.vertical.shapeFolder == "shapes/9x16")
        // Every shape is a multiple of 32, which both models need.
        for aspect in ImageAspect.allCases {
            #expect(aspect.size.width % 32 == 0 && aspect.size.height % 32 == 0)
        }
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

@Suite("Standard output", .serialized)
struct StandardOutputTests {

    /// What reaches stdout while `body` runs, caught in a file.
    private func caught(_ body: () async -> Void) async throws -> String {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("stdout-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: file) }
        fflush(stdout)
        let real = dup(STDOUT_FILENO)
        let sink = open(file.path, O_WRONLY | O_CREAT | O_TRUNC, 0o600)
        dup2(sink, STDOUT_FILENO)
        close(sink)
        await body()
        fflush(stdout)
        dup2(real, STDOUT_FILENO)
        close(real)
        return try String(contentsOf: file, encoding: .utf8)
    }

    @Test("Core AI's warnings go nowhere; stdout comes back after")
    func silenced() async throws {
        let out = try await caught {
            await StandardOutput.silenced { print("warning: loc(fused…") }
            print("[{\"seed\":21}]")
        }
        #expect(!out.contains("warning: loc"))
        #expect(out.contains("[{\"seed\":21}]"))
    }

    @Test("Overlapping uses: stdout comes back only when the last one ends")
    func overlapping() async throws {
        let out = try await caught {
            StandardOutput.divert()
            StandardOutput.divert()
            StandardOutput.restore()
            print("still loading")
            StandardOutput.restore()
            print("the JSON")
        }
        #expect(!out.contains("still loading"))
        #expect(out.contains("the JSON"))
    }
}
