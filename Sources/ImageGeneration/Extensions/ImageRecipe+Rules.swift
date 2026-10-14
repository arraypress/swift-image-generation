//
//  ImageRecipe+Rules.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

public extension ImageRecipe {

    /// The format this library writes, and the newest it reads.
    static let formatVersion = 1

    /// The prompt's parts joined in their fixed order — text, subject,
    /// details, setting, lighting, camera, style, extra. A recipe holding
    /// only `text` composes to exactly that text.
    var composedPrompt: String { RecipeRules.composed(prompt) }

    /// Whether the model is let draw text: `avoid_text` when set, otherwise
    /// the model's default (only FLUX.2 Klein 9B draws text by default).
    var drawsText: Bool { RecipeRules.drawsText(self) }

    /// The prompt the model would be given, suffix included.
    var promptSent: String {
        ImageGenerator.promptSent(for: (try? ImageGenerator.validatedPrompt(composedPrompt)) ?? composedPrompt,
                                  allowText: drawsText)
    }

    /// The edit strength to replay with: `settings.strength`, except from a recipe
    /// written before imagine 0.9.0, when strength had no effect (the replay then
    /// redraws in full, as the original run did).
    var effectiveStrength: Double? { RecipeRules.effectiveStrength(self) }

    /// Whether a replay frames its references around their subjects
    /// (``ReferenceFraming``): not with `inputs.references_full`, nor for a
    /// recipe from before imagine 0.15.0, which sent them whole.
    var framesReferences: Bool { RecipeRules.framesReferences(self) }

    /// The model the settings name, or `nil` when they name none.
    var model: GenerationModel? { settings.model.flatMap(GenerationModel.init(rawValue:)) }

    /// Every path ``setting(_:to:)`` takes, e.g. `settings.seed`. A field may
    /// be named alone too: `seed`, `style`.
    static var settablePaths: [String] { RecipeRules.paths }

    /// This recipe with one field changed, from a value as typed on a command
    /// line: `setting("seed", to: "42")`, `setting("prompt.details", to:
    /// "[\"rusty chain\"]")`. An empty value clears the field. Throws
    /// ``ImageGenerationError/invalidRecipe(_:)`` for an unknown path or a
    /// value the field cannot hold.
    func setting(_ path: String, to value: String) throws(ImageGenerationError) -> ImageRecipe {
        try RecipeRules.set(path, value, in: self)
    }

    /// The recipe as JSON: pretty-printed, keys sorted.
    func encoded() throws(ImageGenerationError) -> Data { try RecipeRules.encoded(self) }

    /// A recipe from JSON. Refuses a newer format, a key it does not know
    /// (a misspelt field would otherwise vanish silently) and a value of the
    /// wrong type, naming the field.
    static func decode(_ data: Data) throws(ImageGenerationError) -> ImageRecipe { try RecipeRules.decoded(data) }
}
