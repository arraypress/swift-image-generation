//
//  ImageStyle.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  A look with several scenes: "hard flash" is a dozen different shots that
//  share a light and a camera, not one prompt. A scene becomes recipe prompt
//  parts once it has a subject, so a picture made from a style can be saved
//  and replayed without the style table. The built-in styles are Swift data
//  (``ImageStyle/all``), not a resource bundle: a bundle beside a Homebrew
//  binary breaks when the binary is reached through a symlink.
//
//  A style may have slots (``StyleSlot``): `{room}` in its scenes, filled
//  by the caller or by the slot's default.
//

import Foundation

/// A named look: a category and several scenes in it.
public struct ImageStyle: Codable, Sendable, Equatable, Identifiable {

    /// Lower-case kebab-case, as typed: `hard-flash`.
    public let name: String

    /// For people: "Hard flash".
    public let title: String

    /// Where it is listed.
    public let category: StyleCategory

    /// The shots; a seed picks one, so the same seed picks the same one.
    public let scenes: [StyleScene]

    /// Gaps in the scenes a caller may fill — `{room}` — each with a
    /// default; empty for most styles.
    public let slots: [StyleSlot]

    public var id: String { name }

    public init(name: String, title: String, category: StyleCategory, scenes: [StyleScene], slots: [StyleSlot] = []) {
        self.name = name
        self.title = title
        self.category = category
        self.scenes = scenes
        self.slots = slots
    }

    enum CodingKeys: String, CodingKey {
        case name, title, category, scenes, slots
    }

    /// `slots` may be left out: a style written before slots has none.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        title = try container.decode(String.self, forKey: .title)
        category = try container.decode(StyleCategory.self, forKey: .category)
        scenes = try container.decode([StyleScene].self, forKey: .scenes)
        slots = try container.decodeIfPresent([StyleSlot].self, forKey: .slots) ?? []
    }
}

/// One shot in a style, as prompt parts around a subject.
public struct StyleScene: Codable, Sendable, Equatable {

    /// Where the subject goes: `{subject} stepping off a tram`. Usually just
    /// `{subject}`; a style with slots may lead with one instead (`{room}`),
    /// and then a subject, when given, joins the details.
    public let who: String

    /// Where: "on a rain-soaked street at night".
    public let setting: String

    /// About the subject or the shot, after what they wear.
    public let details: [String]

    /// The light.
    public let lighting: String?

    /// Lens, framing.
    public let camera: String?

    /// The kind of picture: "editorial fashion photograph".
    public let look: String?

    /// What the subject wears; `nil` when the scene says nothing about it.
    public let wear: Wardrobe?

    public init(who: String = StyleScene.subjectSlot, setting: String, details: [String] = [], lighting: String? = nil,
                camera: String? = nil, look: String? = nil, wear: Wardrobe? = nil) {
        self.who = who
        self.setting = setting
        self.details = details
        self.lighting = lighting
        self.camera = camera
        self.look = look
        self.wear = wear
    }

    /// The marker in ``who`` the subject replaces.
    public static let subjectSlot = "{subject}"
}

/// What a scene's subject wears: neutral wording always, and optionally a
/// feminine or masculine cut of the same idea.
public struct Wardrobe: Codable, Sendable, Equatable {

    /// Wording that assumes nothing: "a camel wool coat over a roll-neck".
    public let neutral: String

    /// The feminine cut, when the idea has one.
    public let feminine: String?

    /// The masculine cut, when the idea has one.
    public let masculine: String?

    public init(neutral: String, feminine: String? = nil, masculine: String? = nil) {
        self.neutral = neutral
        self.feminine = feminine
        self.masculine = masculine
    }
}
