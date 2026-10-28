//
//  RecipeRules.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  The pure parts of a recipe: composing its prompt, reading and writing its
//  JSON, and changing one field by path. Strict on purpose — JSONDecoder
//  ignores keys it does not know, so `"lightning": "dusk"` would vanish
//  without a word and the picture would quietly differ from the one meant.
//  The JSON and `--set` engines are RecipeKit's, shared with song; what is
//  imagine's own is the format, the field-kind table and the composer.
//

import Foundation
import RecipeKit

enum RecipeRules {

    // MARK: Composing

    /// The prompt's parts in the fixed order — text, subject, details,
    /// setting, lighting, camera, style, extra — joined with ", ".
    ///
    /// A single part comes back as written (trimmed), so a recipe holding a
    /// typed prompt as `text` sends exactly what typing it sent. Several are
    /// each stripped of trailing punctuation first, so "dusk." does not
    /// become "dusk., film".
    static func composed(_ prompt: ImageRecipe.Prompt) -> String {
        let parts = ([prompt.text, prompt.subject] + (prompt.details ?? []).map(Optional.some)
            + [prompt.setting, prompt.lighting, prompt.camera, prompt.style] + (prompt.extra ?? []).map(Optional.some))
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard parts.count > 1 else { return parts.first ?? "" }
        return parts.map(trimmedOfPunctuation).filter { !$0.isEmpty }.joined(separator: ", ")
    }

    /// A part without the punctuation and space it ends in.
    static func trimmedOfPunctuation(_ part: String) -> String {
        var part = part
        while let last = part.last, last == "." || last == "," || last == ";" || last.isWhitespace {
            part.removeLast()
        }
        return part
    }

    /// Whether the model draws text: what the recipe says, or the model's
    /// default — FLUX.2 Klein 9B and FLUX.3 Klein are the models chosen for their text.
    static func drawsText(_ recipe: ImageRecipe) -> Bool {
        if let avoid = recipe.prompt.avoidText { return !avoid }
        return recipe.settings.model.flatMap(GenerationModel.init(rawValue:))?.drawsTextByDefault ?? false
    }

    /// The strength a replay should use. Before imagine 0.9.0 the pipeline never read
    /// strength — every edit was a full redraw whatever the recipe said, and edits
    /// recorded 0.85 by default — so an older recipe's strength is dropped and the
    /// replay draws what it drew then.
    static func effectiveStrength(_ recipe: ImageRecipe) -> Double? {
        guard let strength = recipe.settings.strength else { return nil }
        guard let tool = recipe.provenance?.tool,
              let version = tool.split(separator: " ").last.map(String.init) else { return strength }
        return isBefore(version, "0.9.0") ? nil : strength
    }

    /// Whether a replay frames its references around their subjects: not when
    /// the recipe says `references_full`, nor for a recipe written before
    /// imagine 0.15.0, which sent every reference whole — so it replays as it drew.
    static func framesReferences(_ recipe: ImageRecipe) -> Bool {
        if recipe.inputs?.referencesFull == true { return false }
        guard let tool = recipe.provenance?.tool,
              let version = tool.split(separator: " ").last.map(String.init) else { return true }
        return !isBefore(version, "0.15.0")
    }

    /// Whether dotted version `a` sorts before `b`, numerically per part.
    static func isBefore(_ a: String, _ b: String) -> Bool {
        let left = a.split(separator: ".").map { Int($0) ?? 0 }
        let right = b.split(separator: ".").map { Int($0) ?? 0 }
        for index in 0..<max(left.count, right.count) {
            let l = index < left.count ? left[index] : 0
            let r = index < right.count ? right[index] : 0
            if l != r { return l < r }
        }
        return false
    }

    // MARK: JSON

    /// The keys a recipe file may hold.
    static let format = RecipeFormat(
        versionKey: "imagine", version: ImageRecipe.formatVersion, rootKeys: ImageRecipe.CodingKeys.allCases.map(\.rawValue),
        sections: [
            .init("prompt", keys: ImageRecipe.Prompt.CodingKeys.allCases.map(\.rawValue)),
            .init("settings", keys: ImageRecipe.Settings.CodingKeys.allCases.map(\.rawValue)),
            .init("inputs", keys: ImageRecipe.Inputs.CodingKeys.allCases.map(\.rawValue)),
            .init("provenance", keys: ImageRecipe.Provenance.CodingKeys.allCases.map(\.rawValue)),
        ])

    /// Pretty, key-sorted JSON with slashes left alone, as the fleet writes recipes.
    static func encoded(_ recipe: ImageRecipe) throws(ImageGenerationError) -> Data {
        do { return try RecipeJSON.encoded(recipe) } catch { throw .invalidRecipe(error.message) }
    }

    /// A recipe from JSON, refusing a newer format and any key it does not know.
    static func decoded(_ data: Data) throws(ImageGenerationError) -> ImageRecipe {
        do { return try RecipeJSON.decoded(data, format: format, check: checkSeed) } catch { throw .invalidRecipe(error.message) }
    }

    /// The one field whose range a type cannot say: JSONDecoder reports a
    /// seed of -1 with no path at all.
    static func checkSeed(_ root: [String: Any]) throws(RecipeError) {
        if let seed = (root["settings"] as? [String: Any])?["seed"] as? NSNumber,
           !(0...Double(UInt32.max)).contains(seed.doubleValue) || seed.doubleValue.rounded() != seed.doubleValue {
            throw RecipeError("settings.seed is a whole number 0–\(UInt32.max); not \(seed)")
        }
    }

    // MARK: Changing one field

    /// Every path ``set(_:_:in:)`` takes. A field may also be named alone
    /// (`seed`, `style`) — every leaf name is unique.
    static let paths: [String] =
        ImageRecipe.Prompt.CodingKeys.allCases.map { "prompt." + $0.rawValue }
        + ImageRecipe.Settings.CodingKeys.allCases.map { "settings." + $0.rawValue }
        + ImageRecipe.Inputs.CodingKeys.allCases.map { "inputs." + $0.rawValue }

    /// What each field holds: the table `--set` reads values by.
    static let kinds: [String: FieldKind] = [
        "prompt.text": .text, "prompt.subject": .text, "prompt.details": .list, "prompt.setting": .text,
        "prompt.lighting": .text, "prompt.camera": .text, "prompt.style": .text, "prompt.extra": .list,
        "prompt.avoid_text": .bool,
        "settings.model": .choice(GenerationModel.allCases.map(\.rawValue)),
        "settings.aspect": .choice(ImageAspect.allCases.map(\.rawValue)),
        "settings.seed": .integer(0...Int(UInt32.max)),
        "settings.steps": .integer(), "settings.count": .integer(), "settings.upscale": .integer(),
        "settings.strength": .number, "settings.fix_faces": .bool,
        "settings.person": .custom { text, name throws(RecipeError) in
            guard Person.isValidName(text) else { throw RecipeError("\(name) is a person's name (\(Person.nameRule)); not \(text)") }
            return text
        },
        "inputs.edit": .text, "inputs.only": .list, "inputs.replace": .list, "inputs.references": .list,
        "inputs.mask_min_score": .number, "inputs.references_full": .bool, "inputs.beside": .bool,
    ]

    /// `recipe` with the field at `path` set from `value`, as typed on a
    /// command line (read exactly as typed, not trimmed). An empty value
    /// clears the field. Lists take a JSON array (`["rusty chain", "basket"]`) or one item.
    static func set(_ path: String, _ value: String, in recipe: ImageRecipe) throws(ImageGenerationError) -> ImageRecipe {
        guard let full = FieldPaths.resolve(path, among: paths) else {
            throw .invalidRecipe("\(path) is not a recipe field (\(paths.joined(separator: ", ")))")
        }
        guard let kind = kinds[full] else { throw .invalidRecipe("\(full) cannot be set") }
        var recipe = recipe
        recipe.inputs = recipe.inputs ?? ImageRecipe.Inputs()
        do {
            recipe = try FieldSetter.set(full, to: value, kind: kind, in: recipe, trims: false) { _ in
                RecipeError("\(full) cannot be \(value)")
            }
        } catch {
            throw .invalidRecipe(error.message)
        }
        if recipe.inputs == ImageRecipe.Inputs() { recipe.inputs = nil }
        return recipe
    }
}
