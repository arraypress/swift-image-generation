//
//  RecipeTests.swift
//  ImageGenerationTests
//
//  Created by David Sherlock on 2026.
//
//  Recipes need no model: composing, reading, writing and changing fields.
//  That a recipe and seed make the same picture again is measured through
//  `imagine`, which owns the files.
//

import Foundation
import Testing
@testable import ImageGeneration

@Suite("Recipes")
struct RecipeTests {

    static let full = ImageRecipe(
        prompt: .init(subject: "a red bicycle", details: ["rusty chain", "wicker basket."], setting: "against a blue door",
                      lighting: "late afternoon sun", camera: "35mm, shallow depth of field", style: "film photograph",
                      extra: ["muted colours"], avoidText: true),
        settings: .init(model: "flux2-klein-4b", aspect: "1:1", seed: 7, steps: 4, count: 1),
        inputs: .init(references: ["door.jpg"]),
        provenance: .init(tool: "imagine 0.6.0", modelRevision: "abc"))

    @Test("The parts compose in the fixed order, trailing punctuation dropped")
    func order() {
        #expect(Self.full.composedPrompt == "a red bicycle, rusty chain, wicker basket, against a blue door, "
            + "late afternoon sun, 35mm, shallow depth of field, film photograph, muted colours")
        // Order is the field order, not the order they were set.
        var recipe = ImageRecipe(prompt: .init(style: "watercolour", extra: ["soft"]))
        recipe.prompt.subject = "a fox"
        #expect(recipe.composedPrompt == "a fox, watercolour, soft")
        #expect(ImageRecipe(prompt: .init(text: "a fox", style: "ink.")).composedPrompt == "a fox, ink")
    }

    @Test("A typed prompt as text sends exactly what typing it sent")
    func plainTextRoundTrips() throws {
        for typed in ["a red bicycle against a blue door", "a sign that says OPEN.", "  a fox, at dusk;  "] {
            for allow in [false, true] {
                let recipe = ImageRecipe(prompt: .init(text: typed, avoidText: !allow))
                let again = try ImageRecipe.decode(try recipe.encoded())
                let typedSent = ImageGenerator.promptSent(for: try ImageGenerator.validatedPrompt(typed), allowText: allow)
                #expect(again.promptSent == typedSent, "\(typed) \(allow)")
            }
        }
    }

    @Test("FLUX.2 Klein 9B draws text unless told not to; the others are told not to")
    func textDefaults() {
        #expect(ImageRecipe(prompt: .init(text: "a"), settings: .init(model: "flux2-klein-9b")).drawsText)
        #expect(!ImageRecipe(prompt: .init(text: "a"), settings: .init(model: "flux2-klein-4b")).drawsText)
        #expect(!ImageRecipe(prompt: .init(text: "a")).drawsText)
        #expect(!ImageRecipe(prompt: .init(text: "a", avoidText: true), settings: .init(model: "flux2-klein-9b")).drawsText)
        #expect(ImageRecipe(prompt: .init(text: "a", avoidText: false)).drawsText)
    }

    @Test("JSON round-trips, snake_case and versioned")
    func json() throws {
        let data = try Self.full.encoded()
        let text = String(decoding: data, as: UTF8.self)
        #expect(text.contains("\"imagine\" : 1"))
        #expect(text.contains("\"avoid_text\" : true"))
        #expect(text.contains("\"model_revision\" : \"abc\""))
        #expect(try ImageRecipe.decode(data) == Self.full)
        // The smallest recipe is a version and a prompt.
        let small = try ImageRecipe.decode(Data(#"{"imagine": 1, "prompt": {"text": "a fox"}}"#.utf8))
        #expect(small.composedPrompt == "a fox" && small.settings == .init() && small.inputs == nil)
    }

    @Test("A styled recipe records its style, scene and slot values, and they round-trip")
    func styleProvenance() throws {
        var recipe = Self.full
        recipe.provenance = .init(tool: "imagine 0.14.0", style: "japandi", scene: 2, vars: ["room": "kitchen"])
        let data = try recipe.encoded()
        #expect(String(decoding: data, as: UTF8.self).contains(#""vars" : {"#))
        #expect(try ImageRecipe.decode(data) == recipe)
        // Old recipes without them still read.
        let old = #"{"imagine": 1, "prompt": {"text": "a fox"}, "provenance": {"tool": "imagine 0.6.0"}}"#
        #expect(try ImageRecipe.decode(Data(old.utf8)).provenance?.vars == nil)
    }

    @Test("Unknown keys, newer formats and wrong types are refused, naming the field")
    func strict() {
        let cases: [(String, String)] = [
            (#"{"imagine": 1, "prompt": {"lightning": "dusk"}, "settings": {}}"#, "prompt.lightning"),
            (#"{"imagine": 1, "prompt": {"text": "a"}, "setings": {}}"#, "setings"),
            (#"{"imagine": 2, "prompt": {"text": "a"}, "settings": {}}"#, "format 2"),
            (#"{"prompt": {"text": "a"}, "settings": {}}"#, "\"imagine\""),
            (#"{"imagine": 1, "prompt": {"text": "a"}, "settings": {"seed": "seven"}}"#, "settings.seed"),
            (#"{"imagine": 1, "prompt": {"text": "a"}, "settings": {"seed": -1}}"#, "settings.seed"),
            ("[1]", "object"), ("not json", "JSON"),
        ]
        for (json, named) in cases {
            do {
                _ = try ImageRecipe.decode(Data(json.utf8))
                Issue.record("accepted \(json)")
            } catch {
                #expect(error.localizedDescription.contains(named), "\(json): \(error.localizedDescription)")
            }
        }
    }

    @Test("--set paths: full or bare, typed values, empty clears")
    func set() throws {
        var recipe = try Self.full.setting("settings.seed", to: "42")
        #expect(recipe.settings.seed == 42)
        recipe = try recipe.setting("style", to: "oil painting")
        #expect(recipe.prompt.style == "oil painting")
        recipe = try recipe.setting("details", to: #"["chrome bell", "white tyres"]"#)
        #expect(recipe.prompt.details == ["chrome bell", "white tyres"])
        recipe = try recipe.setting("extra", to: "grain, faded")
        #expect(recipe.prompt.extra == ["grain, faded"])
        recipe = try recipe.setting("avoid_text", to: "no").setting("model", to: "sana-sprint-1.6b")
        #expect(recipe.prompt.avoidText == false && recipe.model == .sanaSprint16B)
        recipe = try recipe.setting("references", to: "").setting("strength", to: "0.6")
        #expect(recipe.inputs == nil && recipe.settings.strength == 0.6)
        recipe = try recipe.setting("only", to: "jacket")
        #expect(recipe.inputs?.only == ["jacket"])
        // Only the one field changed.
        #expect(recipe.prompt.subject == Self.full.prompt.subject && recipe.settings.aspect == Self.full.settings.aspect)
    }

    @Test("Unknown paths and bad values are refused")
    func setRefused() {
        for (path, value) in [("settings.colour", "red"), ("lightning", "dusk"), ("seed", "seven"), ("seed", "-1"),
                              ("steps", "4.5"), ("model", "flux"), ("aspect", "5:4"), ("avoid_text", "maybe"),
                              ("strength", "nan"), ("details", "[1, 2]"), ("provenance.tool", "x"), ("imagine", "2")] {
            #expect(throws: ImageGenerationError.self, "\(path)=\(value)") { try Self.full.setting(path, to: value) }
        }
    }

    @Test("Strength replays only from recipes written once it worked (0.9.0)")
    func strengthByVersion() {
        var recipe = ImageRecipe(prompt: .init(text: "a fox"), settings: .init(strength: 0.85),
                                 provenance: .init(tool: "imagine 0.8.0"))
        #expect(recipe.effectiveStrength == nil)
        recipe.provenance = .init(tool: "imagine 0.9.0")
        #expect(recipe.effectiveStrength == 0.85)
        recipe.provenance = .init(tool: "imagine 0.10.2")
        #expect(recipe.effectiveStrength == 0.85)
        recipe.provenance = nil  // hand-written: taken at its word
        #expect(recipe.effectiveStrength == 0.85)
        recipe.settings.strength = nil
        #expect(recipe.effectiveStrength == nil)
        #expect(RecipeRules.isBefore("0.8.9", "0.9.0") && !RecipeRules.isBefore("0.9", "0.9.0"))
    }

    @Test("References are framed on replay only for recipes written once framing existed (0.15.0)")
    func framingByVersion() throws {
        var recipe = ImageRecipe(prompt: .init(text: "a fox"), inputs: .init(references: ["mug.png"]),
                                 provenance: .init(tool: "imagine 0.14.0"))
        #expect(!recipe.framesReferences)
        recipe.provenance = .init(tool: "imagine 0.15.0")
        #expect(recipe.framesReferences)
        recipe.provenance = nil
        #expect(recipe.framesReferences)
        recipe = try recipe.setting("references_full", to: "true")
        #expect(!recipe.framesReferences)
        recipe = try recipe.setting("beside", to: "yes")
        #expect(recipe.inputs?.beside == true)
        let json = String(decoding: try recipe.encoded(), as: UTF8.self)
        #expect(json.contains("\"references_full\" : true") && json.contains("\"beside\" : true"))
        #expect(try ImageRecipe.decode(Data(json.utf8)) == recipe)
    }
}
