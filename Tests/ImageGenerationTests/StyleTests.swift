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
                    #expect(text.hasPrefix("a fox in a hat"), "\(style.name) \(index): \(text)")
                    #expect(!text.contains(StyleScene.subjectSlot))
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
                let text = ImageRecipe(prompt: style.prompt(scene: index, subject: "a person")).composedPrompt
                #expect(Self.sharedRuns(text, source).isEmpty, "\(style.name) \(index)")
            }
        }
    }
}
