//
//  StyleSlot.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  A named gap in a style's scenes — `{room}` — that a caller fills: one
//  interior style serves a kitchen, a hallway or a hotel lobby without a
//  style per room. A slot has a default, so a style always composes, and
//  may list the values it knows; a known value can stand for a longer
//  phrase ("kitchen" → "a kitchen with fitted cabinets, …"). Any other
//  value goes into the prompt as typed.
//

import Foundation

/// A gap in a style's scenes, written `{name}`, and what may fill it.
public struct StyleSlot: Codable, Sendable, Equatable {

    /// Lower-case, as written in the scenes and typed: `room`.
    public let name: String

    /// The value used when none is given: one of ``known``'s names.
    public let defaultValue: String

    /// The values this slot was written for, in listing order; the first is the default.
    public let known: [Value]

    public init(name: String, defaultValue: String, known: [Value]) {
        self.name = name
        self.defaultValue = defaultValue
        self.known = known
    }

    /// The marker scenes use for this slot: `{room}`.
    public var marker: String { "{\(name)}" }

    /// One value a slot knows.
    public struct Value: Codable, Sendable, Equatable {

        /// As typed: `home office`.
        public let name: String

        /// What goes into the prompt, when it says more than the name:
        /// "a home office with a desk facing the window, …".
        public let phrase: String?

        public init(name: String, phrase: String? = nil) {
            self.name = name
            self.phrase = phrase
        }

        /// The words a prompt gets for this value.
        public var text: String { phrase ?? name }
    }
}
