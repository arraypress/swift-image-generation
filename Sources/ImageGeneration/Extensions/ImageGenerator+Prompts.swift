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

    /// The prompt the model would be given.
    static func promptSent(for prompt: String, allowText: Bool) -> String {
        PromptText.composed(prompt, allowText: allowText)
    }
}
