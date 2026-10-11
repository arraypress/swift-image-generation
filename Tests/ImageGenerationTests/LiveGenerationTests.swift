//
//  LiveGenerationTests.swift
//  ImageGenerationTests
//
//  Created by David Sherlock on 2026.
//
//  The real models, when their exports are named:
//      IMAGE_GENERATION_FLUX=<folder> IMAGE_GENERATION_SANA=<folder> swift test
//  Skipped otherwise — each export is 8–20 GB.
//

import CoreGraphics
import Foundation
import Testing
@testable import ImageGeneration

private let fluxFolder = ProcessInfo.processInfo.environment["IMAGE_GENERATION_FLUX"]
private let sanaFolder = ProcessInfo.processInfo.environment["IMAGE_GENERATION_SANA"]

@Suite("Live generation", .serialized)
struct LiveGenerationTests {

    @Test("SANA: same seed, same bytes; seeds count up; no editing", .enabled(if: sanaFolder != nil))
    func sana() async throws {
        let generator = try await ImageGenerator(bundle: URL(fileURLWithPath: try #require(sanaFolder)))
        #expect(generator.model == .sanaSprint16B)
        #expect(!generator.supportsEditing)
        let first = try await generator.generate("three red apples on a wooden table, photograph", seed: 1006, count: 2)
        #expect(first.map(\.seed) == [1006, 1007])
        #expect(first.allSatisfy { $0.image.width == 1024 && $0.image.height == 1024 })
        let again = try await generator.generate("three red apples on a wooden table, photograph", seed: 1006)
        #expect(Fixture.pixels(first[0].image) == Fixture.pixels(again[0].image), "a seed makes one picture")
        #expect(Fixture.pixels(first[0].image) != Fixture.pixels(first[1].image))
        let source = try #require(Fixture.image(width: 64, height: 64))
        await #expect(throws: ImageGenerationError.self) { try await generator.edit(source, "make it night") }
    }

    @Test("SANA 16:9: 1344 x 768, deterministic, and it refuses to edit", .enabled(if: sanaFolder != nil))
    func sanaWide() async throws {
        let folder = URL(fileURLWithPath: try #require(sanaFolder)).appendingPathComponent("aspect-16x9")
        try #require(FileManager.default.fileExists(atPath: folder.path), "no 16:9 export beside \(folder.path)")
        let generator = try await ImageGenerator(bundle: folder)
        #expect(generator.size == (1344, 768))
        let one = try await generator.generate("a lighthouse on a rocky coast at sunset", seed: 11)
        let two = try await generator.generate("a lighthouse on a rocky coast at sunset", seed: 11)
        #expect(one[0].image.width == 1344 && one[0].image.height == 768)
        #expect(Fixture.pixels(one[0].image) == Fixture.pixels(two[0].image))
        #expect(!generator.supportsEditing)
    }

    @Test("FLUX: same seed, same bytes; it edits", .enabled(if: fluxFolder != nil))
    func flux() async throws {
        let generator = try await ImageGenerator(bundle: URL(fileURLWithPath: try #require(fluxFolder)), lowMemory: true)
        #expect(generator.model == .flux2Klein4B)
        let one = try await generator.generate("a black ceramic mug on white, studio product photo", seed: 1001)
        let two = try await generator.generate("a black ceramic mug on white, studio product photo", seed: 1001)
        #expect(Fixture.pixels(one[0].image) == Fixture.pixels(two[0].image))
        if generator.supportsEditing {
            let edited = try await generator.edit(one[0].image, "make the mug bright red", seed: 5)
            #expect(edited.edited && edited.image.width == 1024)
        }
    }
}
