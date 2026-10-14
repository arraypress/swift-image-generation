//
//  StyleTests.swift
//  ImageGenerationTests
//
//  Created by David Sherlock on 2026.
//
//  The built-in styles need no model: they parse, every scene composes, and
//  a seed picks the same scene every time.
//

import Foundation
import Testing
@testable import ImageGeneration

@Suite("Styles")
struct StyleTests {

    @Test("The built-in text parses without a single unreadable line")
    func parsesCleanly() {
        let result = StyleCatalog.parse(StyleText.all)
        #expect(result.problems.isEmpty, "\(result.problems)")
        #expect(result.styles == ImageStyle.all)
        #expect(ImageStyle.all.count >= 80)
    }

    @Test("Names are unique lower-case kebab-case; every style has six scenes or more")
    func namesAndSizes() {
        let names = ImageStyle.all.map(\.name)
        #expect(Set(names).count == names.count)
        for style in ImageStyle.all {
            #expect(style.name.range(of: "^[a-z0-9]+(-[a-z0-9]+)*$", options: .regularExpression) != nil, "\(style.name)")
            #expect(style.scenes.count >= 6, "\(style.name) has \(style.scenes.count) scenes")
            #expect(!style.title.isEmpty)
        }
        #expect(Set(ImageStyle.all.map(\.category)) == Set(StyleCategory.allCases))
    }

    @Test("Every scene composes around a subject, in every wardrobe, within the prompt limit")
    func everySceneComposes() throws {
        for style in ImageStyle.all {
            for index in style.scenes.indices {
                for wear in WardrobeChoice.allCases {
                    let prompt = style.prompt(scene: index, subject: "a fox in a hat", wear: wear)
                    let text = ImageRecipe(prompt: prompt).composedPrompt
                    if style.takesSubject {
                        #expect(text.hasPrefix("a fox in a hat"), "\(style.name) \(index): \(text)")
                    } else {
                        // A style that leads with a slot takes the subject as its first detail.
                        #expect(prompt.details?.first == "a fox in a hat", "\(style.name) \(index): \(text)")
                    }
                    #expect(!text.contains("{") && !text.contains("}"), "\(style.name) \(index): \(text)")
                    #expect(text.count < 600, "\(style.name) \(index) is \(text.count) characters")
                    _ = try ImageGenerator.validatedPrompt(text)
                }
            }
        }
    }

    @Test("A seed picks a scene; consecutive seeds walk through them")
    func seedPicksScene() throws {
        let style = try #require(ImageStyle.named("Hard-Flash "))
        let count = style.scenes.count
        #expect(style.sceneIndex(seed: 0) == 0)
        #expect(style.sceneIndex(seed: 7) == 7 % count)
        #expect(style.sceneIndex(seed: UInt32(count)) == 0)
        #expect((0..<UInt32(count)).map(style.sceneIndex(seed:)) == Array(0..<count))
        #expect(ImageStyle.named("no-such-style") == nil)
    }

    @Test("Wardrobe cuts fall back to the neutral wording; none says nothing")
    func wardrobe() {
        let both = Wardrobe(neutral: "a coat", feminine: "a dress", masculine: "a suit")
        let neutralOnly = Wardrobe(neutral: "a coat")
        #expect(StyleCatalog.clothes(both, .feminine) == "a dress")
        #expect(StyleCatalog.clothes(both, .masculine) == "a suit")
        #expect(StyleCatalog.clothes(neutralOnly, .feminine) == "a coat")
        #expect(StyleCatalog.clothes(both, .none) == nil)
        #expect(StyleCatalog.wardrobe("a coat /  / a suit") == Wardrobe(neutral: "a coat", masculine: "a suit"))
        let scene = StyleScene(setting: "in the rain", wear: both)
        #expect(ImageRecipe(prompt: scene.prompt(subject: "a fox", wear: .none)).composedPrompt == "a fox, in the rain")
        #expect(ImageRecipe(prompt: scene.prompt(subject: " ", wear: .neutral)).composedPrompt
            == "a person, wearing a coat, in the rain")
    }

    @Test("Style keys carry to every scene; a scene's own win; details join scene-first")
    func inheritance() throws {
        let text = """
        ## test-style | Test | art
        look: ink drawing
        light: soft
        with: crisp edges
        - on a hill | light: dawn | with: a kite
        - in a field | who: {subject} running
        """
        let result = StyleCatalog.parse(text)
        #expect(result.problems.isEmpty)
        let style = try #require(result.styles.first)
        #expect(style.scenes[0] == StyleScene(setting: "on a hill", details: ["a kite", "crisp edges"], lighting: "dawn",
                                              look: "ink drawing"))
        #expect(ImageRecipe(prompt: style.prompt(scene: 1, subject: "a fox")).composedPrompt
            == "a fox running, crisp edges, in a field, soft, ink drawing")
    }

    @Test("A role scene leads with the subject: the role reads before the clothes")
    func roleFirst() {
        let scene = StyleScene(setting: "as a wizard with an oversized hat", wear: Wardrobe(neutral: "a starry robe"))
        #expect(ImageRecipe(prompt: scene.prompt(subject: "a fox", wear: .neutral)).composedPrompt
            == "a fox as a wizard with an oversized hat, wearing a starry robe")
        #expect(StyleCatalog.isRole("As a knight"))
        #expect(!StyleCatalog.isRole("ascending a staircase"))
        // No built-in scene puts a role after the clothes any more.
        for style in ImageStyle.all {
            for index in style.scenes.indices {
                let text = ImageRecipe(prompt: style.prompt(scene: index, subject: "a person", wear: .neutral)).composedPrompt
                #expect(!text.contains(", as a ") && !text.contains(", as an "), "\(style.name) \(index + 1): \(text)")
            }
        }
    }

    @Test("A malformed entry is reported, never silently dropped")
    func problemsAreReported() {
        let bad = """
        ## two-fields | Missing category
        ## ok-style | OK | art
        - who: {subject} | on a hill
        - on a hill | who: a fox
        - on a hill | colour: red
        - on a hill | light: one | light: two
        stray line
        """
        let problems = StyleCatalog.parse(bad).problems
        #expect(problems.count == 7, "\(problems)")  // the six bad lines, then a style left with no scenes
        #expect(StyleCatalog.parse("## lonely | Lonely | art").problems == ["lonely: no scenes"])
    }

    // MARK: Slots

    static let slotted = """
    ## room-test | Room test | interiors
    look: ink drawing of {room}
    who: {room}
    slot: room = living room => a living room with a sofa; walk in closet => a closet with rails; attic
    slot: mood = calm
    - seen from the door | light: a {mood} glow
    - seen from a corner | who: {room} for {subject}
    """

    @Test("A slot line reads: the first value is the default, a phrase may stand behind a value")
    func slotParses() throws {
        let slot = try StyleSlots.parse("room = living room => a living room with a sofa; attic").get()
        #expect(slot.name == "room")
        #expect(slot.defaultValue == "living room")
        #expect(slot.known == [StyleSlot.Value(name: "living room", phrase: "a living room with a sofa"),
                               StyleSlot.Value(name: "attic")])
        #expect(slot.marker == "{room}")
        for bad in ["room", "Room = a", "room = ", "subject = a person", "room = a; A", "room = a =>"] {
            #expect(throws: StyleCatalog.Problem.self, "\(bad)") { try StyleSlots.parse(bad).get() }
        }
        #expect(StyleSlots.markers(in: "{subject} in a {room} at {time-of-day}") == ["subject", "room", "time-of-day"])
    }

    @Test("Slots fill every field; a typed value finds its phrase whatever its case or hyphens; others go in as typed")
    func slotsFill() throws {
        let result = StyleCatalog.parse(Self.slotted)
        #expect(result.problems.isEmpty, "\(result.problems)")
        let style = try #require(result.styles.first)
        #expect(style.slots.map(\.name) == ["room", "mood"])
        #expect(!style.scenes[0].who.contains(StyleScene.subjectSlot))
        // Defaults: no values at all.
        #expect(ImageRecipe(prompt: style.prompt(scene: 0, subject: "")).composedPrompt
            == "a living room with a sofa, seen from the door, a calm glow, ink drawing of a living room with a sofa")
        // A known value by another spelling, a free value, and a subject as the first detail.
        let values = ["room": "Walk-In  Closet", "mood": "stormy"]
        #expect(ImageRecipe(prompt: style.prompt(scene: 0, subject: "with a green chair", vars: values)).composedPrompt
            == "a closet with rails, with a green chair, seen from the door, a stormy glow, ink drawing of a closet with rails")
        #expect(ImageRecipe(prompt: style.prompt(scene: 0, subject: "", vars: ["room": "wine cellar"])).composedPrompt
            .hasPrefix("wine cellar, seen from the door"))
        // A scene that names {subject} still takes it in place, with the default when none is given.
        #expect(ImageRecipe(prompt: style.prompt(scene: 1, subject: "", vars: ["room": "attic"])).composedPrompt
            .hasPrefix("attic for a person, seen from a corner"))
        #expect(style.slot(named: " ROOM ")?.text(for: "living-room") == "a living room with a sofa")
    }

    @Test("Values are checked: an unknown slot names the slots, an empty value is refused, missing ones take defaults")
    func slotValuesAreChecked() throws {
        let style = try #require(StyleCatalog.parse(Self.slotted).styles.first)
        #expect(try style.slotValues([:]) == ["room": "living room", "mood": "calm"])
        #expect(try style.slotValues(["Room": " kitchen "]) == ["room": "kitchen", "mood": "calm"])
        do {
            _ = try style.slotValues(["colour": "red"])
            Issue.record("an unknown slot was accepted")
        } catch {
            #expect(error.localizedDescription.contains("its slots: room, mood"), "\(error.localizedDescription)")
        }
        #expect(throws: ImageGenerationError.self) { try style.slotValues(["room": "  "]) }
        let plain = try #require(ImageStyle.named("old-money"))
        #expect(throws: ImageGenerationError.invalidStyleValue("old-money has no slots to fill; room is not one")) {
            try plain.slotValues(["room": "kitchen"])
        }
        #expect(try plain.slotValues([:]).isEmpty)
    }

    @Test("A marker that is not declared, a slot no scene uses and a misplaced subject are reported")
    func slotProblems() {
        let bad = """
        ## a-style | A | interiors
        slot: room = attic
        slot: unused = x
        - in the {colour} light | who: {room}
        - in the hall | who: {room} | light: lit for {subject}
        - in the hall | who: {room}
        slot: late = y
        """
        let problems = StyleCatalog.parse(bad).problems
        #expect(problems.count == 4, "\(problems)")
        #expect(problems.contains { $0.contains("{colour} is not a slot") })
        #expect(problems.contains { $0.contains("belongs in who: only") })
        #expect(problems.contains { $0.contains("slot late comes twice or after a scene") })
        #expect(problems.contains { $0.contains("slot unused is in no scene") })
    }

    @Test("A style decodes without slots, as one written before them")
    func styleDecodesWithoutSlots() throws {
        let json = #"{"name":"x","title":"X","category":"art","scenes":[{"who":"{subject}","setting":"here","details":[]}]}"#
        let style = try JSONDecoder().decode(ImageStyle.self, from: Data(json.utf8))
        #expect(style.slots.isEmpty)
        let interior = try #require(ImageStyle.named("japandi"))
        #expect(try JSONDecoder().decode(ImageStyle.self, from: JSONEncoder().encode(interior)) == interior)
    }

    // MARK: Interiors

    @Test("Every interior style has the room slot with every room, and composes for each within the limit")
    func interiorsCompose() throws {
        let interiors = ImageStyle.all.filter { $0.category == .interiors }
        #expect(interiors.count >= 45)
        #expect(!StyleCategory.interiors.featuresPeople)
        let rooms = try #require(interiors.first?.slots.first)
        #expect(rooms.name == "room")
        #expect(rooms.defaultValue == "living room")
        #expect(rooms.known.count >= 60)
        #expect(rooms.known.allSatisfy { $0.phrase != nil })
        for style in interiors {
            #expect(style.slots == [rooms], "\(style.name)")
            #expect(!style.takesSubject, "\(style.name)")
            for room in rooms.known {
                for index in style.scenes.indices {
                    let text = ImageRecipe(prompt: style.prompt(scene: index, subject: "", vars: ["room": room.name]))
                        .composedPrompt
                    #expect(text.hasPrefix(room.phrase ?? ""), "\(style.name) \(room.name)")
                    #expect(!text.contains("{"), "\(style.name) \(room.name)")
                    #expect(text.count < 700, "\(style.name) \(room.name) \(index) is \(text.count) characters")
                }
            }
        }
        // Nothing adult: the competitor's adult room types were left out.
        #expect(!rooms.known.contains { $0.name.contains("dungeon") || $0.name.contains("pole") })
    }

    // MARK: The wording gate

    /// Runs of `length` words two texts share, case and punctuation ignored.
    static func sharedRuns(_ text: String, _ source: String, length: Int = 6) -> Set<[String]> {
        func runs(_ text: String) -> Set<[String]> {
            let words = text.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
            guard words.count >= length else { return [] }
            return Set((0...(words.count - length)).map { Array(words[$0..<($0 + length)]) })
        }
        return runs(text).intersection(runs(source))
    }

    /// Made-up phrases standing in for another catalogue's wording. The real
    /// check runs over the real source before a release and is recorded in
    /// the README; nothing from that source belongs in this repository.
    static let fixture = [
        "a purple giraffe reading the evening paper on a crowded tram",
        "Portrait of someone holding a lantern beside a frozen waterfall at midnight",
        "glossy studio shot, bright teal backdrop, the subject balancing three oranges on one hand",
    ]

    @Test("The gate finds a planted overlap, and no scene shares six words with the fixture")
    func wordingGate() {
        #expect(Self.sharedRuns("look: a purple giraffe reading the evening paper, at dusk", Self.fixture[0]).count == 2)
        #expect(Self.sharedRuns("a giraffe reading a paper", Self.fixture[0]).isEmpty)
        let source = Self.fixture.joined(separator: " | ")
        for style in ImageStyle.all {
            for index in style.scenes.indices {
                for value in style.slots.first?.known.map(\.name) ?? [""] {
                    let vars = style.slots.first.map { [$0.name: value] } ?? [:]
                    let text = ImageRecipe(prompt: style.prompt(scene: index, subject: "a person", vars: vars)).composedPrompt
                    #expect(Self.sharedRuns(text, source).isEmpty, "\(style.name) \(index) \(value)")
                }
            }
        }
    }
}
