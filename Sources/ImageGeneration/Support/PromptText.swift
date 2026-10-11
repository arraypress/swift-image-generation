//
//  PromptText.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  What the model is told. Both models invent lettering when a prompt only
//  suggests it — "cover art for a sound effects pack" came back with
//  "SOIN SOON PACK" from FLUX and "ZOUID" from Z-Image — and both misspell
//  real words beyond a short sign. Neither takes a negative prompt (FLUX
//  Klein is guidance-distilled), so the suffix goes in the prompt itself;
//  measured, it removed the invented lettering on every model that added it.
//

import Foundation

enum PromptText {

    /// Appended unless text is allowed.
    static let noTextSuffix = "no text, no letters, no typography"

    /// The longest prompt accepted, in characters — well inside both text
    /// encoders' token windows.
    static let maximumLength = 2000

    /// A usable prompt, trimmed, or an error saying why not.
    static func validated(_ prompt: String) throws(ImageGenerationError) -> String {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw .invalidPrompt("The prompt is empty") }
        guard trimmed.count <= maximumLength else {
            throw .invalidPrompt("The prompt is \(trimmed.count) characters; at most \(maximumLength)")
        }
        return trimmed
    }

    /// The prompt the model is given.
    static func composed(_ prompt: String, allowText: Bool) -> String {
        guard !allowText else { return prompt }
        var base = prompt
        while let last = base.last, last == "." || last == "," || last == ";" || last.isWhitespace {
            base.removeLast()
        }
        return "\(base), \(noTextSuffix)"
    }
}
