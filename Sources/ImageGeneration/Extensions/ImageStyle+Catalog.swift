//
//  ImageStyle+Catalog.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//

import Foundation

public extension ImageStyle {

    /// Every built-in style, by category and then as written.
    static let all: [ImageStyle] = StyleCatalog.parse(StyleText.all).styles

    /// The subject a style uses when none is given: "a person".
    static var defaultSubject: String { StyleCatalog.defaultSubject }

    /// The built-in style with this name, case and surrounding space ignored.
    static func named(_ name: String) -> ImageStyle? {
        let wanted = name.trimmingCharacters(in: .whitespaces).lowercased()
        return all.first { $0.name == wanted }
    }

    /// The scene a seed picks — the same seed, the same scene; consecutive
    /// seeds, consecutive scenes. Zero-based.
    func sceneIndex(seed: UInt32) -> Int { StyleCatalog.sceneIndex(seed: seed, of: scenes.count) }

    /// Scene `index` (zero-based) as recipe prompt parts around `subject`.
    func prompt(scene index: Int, subject: String, wear: WardrobeChoice = .neutral) -> ImageRecipe.Prompt {
        StyleCatalog.prompt(scenes[index], subject: subject, wear: wear)
    }
}

public extension StyleScene {

    /// This scene as recipe prompt parts around `subject`.
    func prompt(subject: String, wear: WardrobeChoice = .neutral) -> ImageRecipe.Prompt {
        StyleCatalog.prompt(self, subject: subject, wear: wear)
    }
}
