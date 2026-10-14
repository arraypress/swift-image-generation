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

import Foundation

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
    static func isName(_ text: String) -> Bool {
        text.range(of: "^[a-z][a-z0-9-]*$", options: .regularExpression) != nil
    }

    /// The names of every `{marker}` in `text`, in order: "{subject} in a {room}" → subject, room.
    static func markers(in text: String) -> [String] {
        // A scan, not a Regex: it runs over every scene each time the
        // catalogue loads, and Swift's Regex made `imagine styles` take a second.
        guard text.contains("{") else { return [] }
        var names: [String] = []
        var open: String?
        for character in text {
            if character == "{" {
                open = ""
            } else if character == "}" {
                if let name = open { names.append(name) }
                open = nil
            } else {
                open?.append(character)
            }
        }
        return names
    }

    // MARK: Values

    /// How a value is compared: case, hyphens, underscores and repeated
    /// spaces ignored, so `Walk-in closet` finds `walk in closet`.
    static func key(_ value: String) -> String {
        value.lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ").joined(separator: " ")
    }

    /// A caller's values checked against a style's slots: every name must be
    /// a slot's and every value non-empty. Returns a value for every slot —
    /// the caller's, or the default — keyed by slot name.
    static func resolved(_ values: [String: String], for slots: [StyleSlot], style: String)
        throws(ImageGenerationError) -> [String: String] {
        var result: [String: String] = [:]
        for (name, value) in values {
            let wanted = name.trimmingCharacters(in: .whitespaces).lowercased()
            guard slots.contains(where: { $0.name == wanted }) else {
                throw .invalidStyleValue(slots.isEmpty
                    ? "\(style) has no slots to fill; \(wanted) is not one"
                    : "\(style) has no slot \"\(wanted)\"; its slots: \(slots.map(\.name).joined(separator: ", "))")
            }
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw .invalidStyleValue("\(wanted) needs a value; \(style)'s default is \(defaultOf(wanted, in: slots))")
            }
            result[wanted] = trimmed
        }
        for slot in slots where result[slot.name] == nil { result[slot.name] = slot.defaultValue }
        return result
    }

    static func defaultOf(_ name: String, in slots: [StyleSlot]) -> String {
        slots.first { $0.name == name }?.defaultValue ?? ""
    }

    /// The known value a typed one names — by its name or an alias — or `nil`.
    static func known(_ value: String, in slot: StyleSlot) -> StyleSlot.Value? {
        let wanted = key(value)
        return slot.known.first { $0.names.contains { key($0) == wanted } }
    }

    /// The words a value puts in the prompt: a known value's phrase, or the value as typed.
    static func text(of value: String, in slot: StyleSlot) -> String {
        known(value, in: slot)?.text ?? value
    }

    /// The value in use for each slot: the given one, or the default.
    static func inUse(_ values: [String: String], for slots: [StyleSlot]) -> [(StyleSlot, String)] {
        slots.map { slot in
            let given = values.first { $0.key.lowercased() == slot.name }?.value
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return (slot, given.flatMap { $0.isEmpty ? nil : $0 } ?? slot.defaultValue)
        }
    }

    /// The tags the values in use carry: `["outdoors"]` for a garden.
    static func tags(_ values: [String: String], for slots: [StyleSlot]) -> Set<String> {
        Set(inUse(values, for: slots).flatMap { known($0.1, in: $0.0)?.tags ?? [] })
    }

    /// The scenes (indices) for these tags: those marked `when:` one of
    /// them, or — when none is — the general scenes. Never empty.
    static func eligible(_ scenes: [StyleScene], tags: Set<String>) -> [Int] {
        let tagged = scenes.indices.filter { scenes[$0].when.map(tags.contains) ?? false }
        if !tagged.isEmpty { return tagged }
        let general = scenes.indices.filter { scenes[$0].when == nil }
        return general.isEmpty ? Array(scenes.indices) : general
    }

    /// Every slot's text for these values; a missing or unknown name takes
    /// the slot's default (callers check names with ``resolved(_:for:style:)``).
    static func texts(_ values: [String: String], for slots: [StyleSlot]) -> [String: String] {
        var texts: [String: String] = [:]
        for (slot, value) in inUse(values, for: slots) { texts[slot.name] = text(of: value, in: slot) }
        return texts
    }

    /// `text` with each `{name}` replaced by its text.
    static func filled(_ text: String, with texts: [String: String]) -> String {
        guard text.contains("{") else { return text }
        var result = text
        for (name, value) in texts { result = result.replacingOccurrences(of: "{\(name)}", with: value) }
        return result
    }
}
