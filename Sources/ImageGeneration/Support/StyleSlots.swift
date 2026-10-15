//
//  StyleSlots.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Slots in a style's scenes — `{room}` — as pure functions: reading a
//  slot's line, checking a caller's values against the style, and filling
//  the markers. Nothing here loads a model.
//
//  A slot is declared on its style, before the scenes, as
//
//      slot: room = living room => a living room with a deep sofa, …; kitchen; hallway
//
//  — the slot's name, then its known values separated by semicolons, the
//  first being the default. `value => phrase` lets a short value stand for
//  a longer phrase in the prompt; `value / alias / alias => phrase` lets
//  other names find it; a trailing `#tag` (`#outdoors`) marks what kind of
//  value it is, which picks the style's scenes marked `when: outdoors` and
//  its `key@outdoors:` wording. A value typed that the slot does not know
//  goes into the prompt as typed, with no tag.
//
//  The slot line is imagine's own; checking values, finding known ones and
//  filling markers are RecipeKit's ``SlotFilling``, shared with song.
//

import Foundation
import RecipeKit

enum StyleSlots {

    /// The subject's marker, which is not a slot: the prompt fills it.
    static let subjectName = "subject"

    // MARK: Reading

    /// A `slot:` line's value, `room = a; b => c`, or why it cannot be one.
    static func parse(_ text: String) -> Swift.Result<StyleSlot, StyleCatalog.Problem> {
        let halves = text.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard halves.count == 2, isName(halves[0]), halves[0] != subjectName else {
            return .failure(.init(reason: "a slot is `name = default; other; …` with a lower-case name: \(text)"))
        }
        var known: [StyleSlot.Value] = []
        var seen: Set<String> = []
        for entry in StyleCatalog.list(halves[1].replacingOccurrences(of: "=>", with: "\u{1}")) {
            let tagged = entry.components(separatedBy: "#").map { $0.trimmingCharacters(in: .whitespaces) }
            let tags = Array(tagged.dropFirst())
            guard tags.allSatisfy(isName) else {
                return .failure(.init(reason: "slot \(halves[0]) has a tag that is not a lower-case name: \(entry)"))
            }
            let parts = tagged[0].split(separator: "\u{1}", maxSplits: 1, omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespaces) }
            let names = parts[0].components(separatedBy: "/").map { $0.trimmingCharacters(in: .whitespaces) }
            guard names.allSatisfy({ !$0.isEmpty }), parts.count == 1 || !parts[1].isEmpty else {
                return .failure(.init(reason: "slot \(halves[0]) has an empty value: \(entry)"))
            }
            for name in names where !seen.insert(key(name)).inserted {
                return .failure(.init(reason: "slot \(halves[0]) lists \(name) twice"))
            }
            known.append(StyleSlot.Value(name: names[0], phrase: parts.count == 2 ? parts[1] : nil,
                                         aliases: names.count > 1 ? Array(names.dropFirst()) : nil,
                                         tags: tags.isEmpty ? nil : tags))
        }
        guard let first = known.first else {
            return .failure(.init(reason: "slot \(halves[0]) has no default: \(text)"))
        }
        return .success(StyleSlot(name: halves[0], defaultValue: first.name, known: known))
    }

    /// Lower-case letters, digits and hyphens, starting with a letter: `room`, `wall-colour`.
    static func isName(_ text: String) -> Bool { SlotFilling.isName(text) }

    /// The names of every `{marker}` in `text`, in order: "{subject} in a {room}" → subject, room.
    static func markers(in text: String) -> [String] { SlotFilling.markers(in: text) }

    // MARK: Values

    /// How a value is compared: case, hyphens, underscores and repeated
    /// spaces ignored, so `Walk-in closet` finds `walk in closet`.
    static func key(_ value: String) -> String { SlotFilling.key(value) }

    /// A caller's values checked against a style's slots: every name must be
    /// a slot's and every value non-empty. Returns a value for every slot —
    /// the caller's, or the default — keyed by slot name.
    static func resolved(_ values: [String: String], for slots: [StyleSlot], style: String)
        throws(ImageGenerationError) -> [String: String] {
        do { return try SlotFilling.resolved(values, for: slots, style: style) } catch {
            throw .invalidStyleValue(error.errorDescription ?? "\(error)")
        }
    }

    /// The known value a typed one names — by its name or an alias — or `nil`.
    static func known(_ value: String, in slot: StyleSlot) -> StyleSlot.Value? { SlotFilling.known(value, in: slot) }

    /// The words a value puts in the prompt: a known value's phrase, or the value as typed.
    static func text(of value: String, in slot: StyleSlot) -> String { SlotFilling.text(of: value, in: slot) }

    /// The tags the values in use carry: `["outdoors"]` for a garden.
    static func tags(_ values: [String: String], for slots: [StyleSlot]) -> Set<String> { SlotFilling.tags(values, for: slots) }

    /// The scenes (indices) for these tags: those marked `when:` one of
    /// them, or — when none is — the general scenes. Never empty.
    static func eligible(_ scenes: [StyleScene], tags: Set<String>) -> [Int] {
        let tagged = scenes.indices.filter { scenes[$0].when.map(tags.contains) ?? false }
        if !tagged.isEmpty { return tagged }
        let general = scenes.indices.filter { scenes[$0].when == nil }
        return general.isEmpty ? Array(scenes.indices) : general
    }

    /// Every slot's text for these values, in slot order; a missing or unknown
    /// name takes the slot's default (callers check names with ``resolved(_:for:style:)``).
    static func texts(_ values: [String: String], for slots: [StyleSlot]) -> [(name: String, text: String)] {
        SlotFilling.texts(values, for: slots)
    }

    /// `text` with each `{name}` replaced by its text, slot by slot.
    static func filled(_ text: String, with texts: [(name: String, text: String)]) -> String {
        SlotFilling.filled(text, with: texts)
    }
}
