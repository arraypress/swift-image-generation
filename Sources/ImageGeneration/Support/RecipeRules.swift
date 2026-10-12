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
//

import Foundation

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
    /// default — FLUX.2 Klein 9B is the model chosen for its text.
    static func drawsText(_ recipe: ImageRecipe) -> Bool {
        if let avoid = recipe.prompt.avoidText { return !avoid }
        return recipe.settings.model == GenerationModel.flux2Klein9B.rawValue
    }

    // MARK: JSON

    /// Pretty, key-sorted JSON with slashes left alone, as the fleet writes recipes.
    static func encoded(_ recipe: ImageRecipe) throws(ImageGenerationError) -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        do { return try encoder.encode(recipe) } catch { throw .invalidRecipe(error.localizedDescription) }
    }

    /// A recipe from JSON, refusing a newer format and any key it does not know.
    static func decoded(_ data: Data) throws(ImageGenerationError) -> ImageRecipe {
        let object: Any
        do { object = try JSONSerialization.jsonObject(with: data) } catch {
            throw .invalidRecipe("it is not JSON")
        }
        guard let root = object as? [String: Any] else { throw .invalidRecipe("it is not a JSON object") }
        guard let version = root["imagine"] as? Int else {
            throw .invalidRecipe("it has no \"imagine\": \(ImageRecipe.formatVersion) — the format version")
        }
        guard version <= ImageRecipe.formatVersion, version >= 1 else {
            throw .invalidRecipe("it is format \(version); this reads format \(ImageRecipe.formatVersion)")
        }
        try unknownKeys(in: root, known: ImageRecipe.CodingKeys.allCases.map(\.rawValue), at: "")
        let sections: [(String, [String])] = [
            ("prompt", ImageRecipe.Prompt.CodingKeys.allCases.map(\.rawValue)),
            ("settings", ImageRecipe.Settings.CodingKeys.allCases.map(\.rawValue)),
            ("inputs", ImageRecipe.Inputs.CodingKeys.allCases.map(\.rawValue)),
            ("provenance", ImageRecipe.Provenance.CodingKeys.allCases.map(\.rawValue)),
        ]
        for (name, known) in sections {
            guard let value = root[name], !(value is NSNull) else { continue }
            guard let section = value as? [String: Any] else { throw .invalidRecipe("\"\(name)\" is not an object") }
            try unknownKeys(in: section, known: known, at: name + ".")
        }
        // The one field whose range a type cannot say: JSONDecoder reports a
        // seed of -1 with no path at all.
        if let seed = (root["settings"] as? [String: Any])?["seed"] as? NSNumber,
           !(0...Double(UInt32.max)).contains(seed.doubleValue) || seed.doubleValue.rounded() != seed.doubleValue {
            throw .invalidRecipe("settings.seed is a whole number 0–\(UInt32.max); not \(seed)")
        }
        do { return try JSONDecoder().decode(ImageRecipe.self, from: data) } catch let DecodingError.typeMismatch(_, context) {
            throw .invalidRecipe("\(path(context.codingPath)) has the wrong type")
        } catch let DecodingError.keyNotFound(key, context) {
            throw .invalidRecipe("\(path(context.codingPath + [key])) is missing")
        } catch let DecodingError.dataCorrupted(context) {
            throw .invalidRecipe("\(path(context.codingPath)) is not a value it can hold")
        } catch {
            throw .invalidRecipe(error.localizedDescription)
        }
    }

    static func unknownKeys(in object: [String: Any], known: [String], at prefix: String) throws(ImageGenerationError) {
        if let unknown = object.keys.sorted().first(where: { !known.contains($0) }) {
            throw .invalidRecipe("\(prefix)\(unknown) is not a recipe field (\(known.map { prefix + $0 }.joined(separator: ", ")))")
        }
    }

    static func path(_ keys: [any CodingKey]) -> String {
        keys.map { $0.intValue.map(String.init) ?? $0.stringValue }.joined(separator: ".")
    }

    // MARK: Changing one field

    /// Every path ``set(_:_:in:)`` takes. A field may also be named alone
    /// (`seed`, `style`) — every leaf name is unique.
    static let paths: [String] =
        ImageRecipe.Prompt.CodingKeys.allCases.map { "prompt." + $0.rawValue }
        + ImageRecipe.Settings.CodingKeys.allCases.map { "settings." + $0.rawValue }
        + ImageRecipe.Inputs.CodingKeys.allCases.map { "inputs." + $0.rawValue }

    /// `recipe` with the field at `path` set from `value`, as typed on a
    /// command line. An empty value clears the field. Lists take a JSON
    /// array (`["rusty chain", "basket"]`) or one item.
    static func set(_ path: String, _ value: String, in recipe: ImageRecipe) throws(ImageGenerationError) -> ImageRecipe {
        let full = paths.contains(path) ? path : paths.first { $0.hasSuffix("." + path) }
        guard let full else {
            throw .invalidRecipe("\(path) is not a recipe field (\(paths.joined(separator: ", ")))")
        }
        var recipe = recipe
        var inputs = recipe.inputs ?? ImageRecipe.Inputs()
        let empty = value.trimmingCharacters(in: .whitespaces).isEmpty
        let text: String? = empty ? nil : value
        switch full {
        case "prompt.text": recipe.prompt.text = text
        case "prompt.subject": recipe.prompt.subject = text
        case "prompt.details": recipe.prompt.details = try list(value, path: full)
        case "prompt.setting": recipe.prompt.setting = text
        case "prompt.lighting": recipe.prompt.lighting = text
        case "prompt.camera": recipe.prompt.camera = text
        case "prompt.style": recipe.prompt.style = text
        case "prompt.extra": recipe.prompt.extra = try list(value, path: full)
        case "prompt.avoid_text": recipe.prompt.avoidText = try empty ? nil : bool(value, path: full)
        case "settings.model":
            if let text, GenerationModel(rawValue: text) == nil {
                throw .invalidRecipe("\(full) is \(GenerationModel.allCases.map(\.rawValue).joined(separator: ", ")); not \(text)")
            }
            recipe.settings.model = text
        case "settings.aspect":
            if let text, ImageAspect(rawValue: text) == nil {
                throw .invalidRecipe("\(full) is \(ImageAspect.allCases.map(\.rawValue).joined(separator: ", ")); not \(text)")
            }
            recipe.settings.aspect = text
        case "settings.seed":
            guard empty || UInt32(value) != nil else { throw .invalidRecipe("\(full) is a whole number 0–\(UInt32.max); not \(value)") }
            recipe.settings.seed = UInt32(value)
        case "settings.steps": recipe.settings.steps = try empty ? nil : integer(value, path: full)
        case "settings.count": recipe.settings.count = try empty ? nil : integer(value, path: full)
        case "settings.upscale": recipe.settings.upscale = try empty ? nil : integer(value, path: full)
        case "settings.strength": recipe.settings.strength = try empty ? nil : number(value, path: full)
        case "inputs.edit": inputs.edit = text
        case "inputs.only": inputs.only = try list(value, path: full)
        case "inputs.replace": inputs.replace = try list(value, path: full)
        case "inputs.references": inputs.references = try list(value, path: full)
        case "inputs.mask_min_score": inputs.maskMinScore = try empty ? nil : number(value, path: full)
        default: throw .invalidRecipe("\(full) cannot be set")
        }
        recipe.inputs = inputs == ImageRecipe.Inputs() ? nil : inputs
        return recipe
    }

    static func integer(_ value: String, path: String) throws(ImageGenerationError) -> Int {
        guard let number = Int(value) else { throw .invalidRecipe("\(path) is a whole number; not \(value)") }
        return number
    }

    static func number(_ value: String, path: String) throws(ImageGenerationError) -> Double {
        guard let number = Double(value), number.isFinite else { throw .invalidRecipe("\(path) is a number; not \(value)") }
        return number
    }

    static func bool(_ value: String, path: String) throws(ImageGenerationError) -> Bool {
        switch value.lowercased() {
        case "true", "yes", "1": return true
        case "false", "no", "0": return false
        default: throw .invalidRecipe("\(path) is true or false; not \(value)")
        }
    }

    static func list(_ value: String, path: String) throws(ImageGenerationError) -> [String]? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        guard trimmed.hasPrefix("[") else { return [value] }
        guard let items = try? JSONSerialization.jsonObject(with: Data(trimmed.utf8)) as? [String] else {
            throw .invalidRecipe("\(path) takes one item or a JSON array of strings: [\"a\", \"b\"]")
        }
        return items.isEmpty ? nil : items
    }
}
