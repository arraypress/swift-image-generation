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

    /// Scene `index` (zero-based) as recipe prompt parts around `subject`,
    /// its slots filled from `vars` (slot name → value) or their defaults.
    /// A known value puts in its phrase, any other value itself; a name that
    /// is not a slot is ignored here — check them first with ``slotValues(_:)``.
    func prompt(scene index: Int, subject: String, wear: WardrobeChoice = .neutral,
                vars: [String: String] = [:]) -> ImageRecipe.Prompt {
        StyleCatalog.prompt(scenes[index], subject: subject, wear: wear, slots: StyleSlots.texts(vars, for: slots))
    }

    /// `vars` checked against this style's slots, completed with defaults:
    /// a value for every slot, keyed by slot name. Throws
    /// ``ImageGenerationError/invalidStyleValue(_:)`` for a name that is not
    /// a slot (the message names the slots) or an empty value.
    func slotValues(_ vars: [String: String]) throws(ImageGenerationError) -> [String: String] {
        try StyleSlots.resolved(vars, for: slots, style: name)
    }

    /// Whether the scenes have a place for a subject. A style that leads
    /// with a slot instead — a room — takes a subject as an extra detail.
    var takesSubject: Bool { scenes.contains { $0.who.contains(StyleScene.subjectSlot) } }

    /// The slot with this name, case ignored.
    func slot(named name: String) -> StyleSlot? {
        let wanted = name.trimmingCharacters(in: .whitespaces).lowercased()
        return slots.first { $0.name == wanted }
    }
}

public extension StyleSlot {

    /// The words a value puts in the prompt: a known value's phrase (case,
    /// hyphens and spacing ignored when matching), otherwise the value itself.
    func text(for value: String) -> String { StyleSlots.text(of: value, in: self) }
}

public extension StyleScene {

    /// This scene as recipe prompt parts around `subject`.
    func prompt(subject: String, wear: WardrobeChoice = .neutral) -> ImageRecipe.Prompt {
        StyleCatalog.prompt(self, subject: subject, wear: wear)
    }
}
