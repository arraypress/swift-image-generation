//
//  ImageGenerator+Prompts.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

public extension ImageGenerator {

    /// What is appended to a prompt unless text is allowed.
    static var noTextSuffix: String { PromptText.noTextSuffix }

    /// The longest prompt accepted, in characters.
    static var maximumPromptLength: Int { PromptText.maximumLength }

    /// A prompt as ``generate(_:seed:count:allowText:progress:)`` would take
    /// it — trimmed — or the reason it would refuse it. For checking input
    /// before loading a model.
    static func validatedPrompt(_ prompt: String) throws(ImageGenerationError) -> String {
        try PromptText.validated(prompt)
    }

    /// The seeds a run of `count` would use: `start` (random when `nil`) and
    /// the next ones up. Lets a caller name its files before loading a model;
    /// passing each seed to `generate(_:seed:count:allowText:progress:)` with
    /// `count: 1` makes the same pictures as one run.
    static func seeds(start: UInt32?, count: Int) -> [UInt32] {
        SeedPlan.seeds(start: start, count: count)
    }

    /// The prompt the model would be given.
    static func promptSent(for prompt: String, allowText: Bool) -> String {
        PromptText.composed(prompt, allowText: allowText)
    }
}
