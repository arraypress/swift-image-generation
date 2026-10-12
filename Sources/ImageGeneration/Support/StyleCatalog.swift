//
//  StyleCatalog.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  The built-in styles are written in a small line format (`StyleText`) so
//  that ~800 scenes stay readable and reviewable as prose. This turns that
//  text into ``ImageStyle`` values and composes a scene into recipe prompt
//  parts. Pure: nothing here loads a model.
//
//  The format:
//
//      ## hard-flash | Hard flash | fashion
//      look: flash photograph, punchy contrast
//      light: a bare on-camera flash
//      camera: 28mm, eye level
//      wear: a black leather jacket / a slip dress under a leather jacket / a leather jacket over a white tee
//      with: a crisp shadow behind
//      - against a bare white wall | who: {subject} laughing, head thrown back
//      - in a lift with mirrored walls | light: flash bouncing off the mirrors
//
//  A style's `look`, `light`, `camera` and `wear` are each scene's unless the
//  scene says otherwise; its `with` details follow the scene's own. `wear` is
//  neutral / feminine / masculine, the last two optional. Detail lists are
//  separated by semicolons, because the details themselves use commas.
//

import Foundation

enum StyleCatalog {

    /// What a parse found, and every line it could not use — a test asserts
    /// there are none, so a malformed entry fails the build, not a run.
    struct Result {
        var styles: [ImageStyle] = []
        var problems: [String] = []
    }

    /// The subject used when none is given.
    static let defaultSubject = "a person"

    // MARK: Parsing

    static func parse(_ texts: [String]) -> Result {
        var result = Result()
        for text in texts {
            let one = parse(text)
            result.styles += one.styles
            result.problems += one.problems
        }
        return result
    }

    static func parse(_ text: String) -> Result {
        var result = Result()
        var header: (name: String, title: String, category: StyleCategory)?
        var shared: [String: String] = [:]
        var scenes: [StyleScene] = []

        func close() {
            guard let open = header else { return }
            if scenes.isEmpty { result.problems.append("\(open.name): no scenes") }
            result.styles.append(ImageStyle(name: open.name, title: open.title, category: open.category, scenes: scenes))
            header = nil
            shared = [:]
            scenes = []
        }

        for raw in text.split(separator: "\n", omittingEmptySubsequences: true) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { continue }
            if line.hasPrefix("## ") {
                close()
                let fields = fields(of: String(line.dropFirst(3)))
                guard fields.count == 3, let category = StyleCategory(rawValue: fields[2]) else {
                    result.problems.append("bad header: \(line)")
                    continue
                }
                header = (fields[0], fields[1], category)
            } else if line.hasPrefix("- ") {
                guard let open = header else {
                    result.problems.append("a scene outside a style: \(line)")
                    continue
                }
                switch scene(String(line.dropFirst(2)), shared: shared) {
                case .success(let scene): scenes.append(scene)
                case .failure(let problem): result.problems.append("\(open.name): \(problem.reason)")
                }
            } else if let (key, value) = keyed(line), keys.contains(key), header != nil {
                shared[key] = value
            } else {
                result.problems.append("\(header?.name ?? "?"): cannot read \(line)")
            }
        }
        close()
        return result
    }

    /// The keys a style or a scene may set.
    static let keys: Set<String> = ["look", "light", "camera", "wear", "with", "who"]

    struct Problem: Error {
        let reason: String
    }

    /// One scene line: the setting, then `key: value` fields.
    static func scene(_ line: String, shared: [String: String]) -> Swift.Result<StyleScene, Problem> {
        var parts = fields(of: line)
        guard !parts.isEmpty, keyed(parts[0]) == nil, !parts[0].isEmpty else {
            return .failure(Problem(reason: "a scene starts with its setting: \(line)"))
        }
        let setting = parts.removeFirst()
        var own: [String: String] = [:]
        for part in parts {
            guard let (key, value) = keyed(part), keys.contains(key), own[key] == nil else {
                return .failure(Problem(reason: "cannot read \"\(part)\" in: \(line)"))
            }
            own[key] = value
        }
        let who = own["who"] ?? shared["who"] ?? StyleScene.subjectSlot
        guard who.contains(StyleScene.subjectSlot) else {
            return .failure(Problem(reason: "who: has no \(StyleScene.subjectSlot) in: \(line)"))
        }
        let details = list(own["with"]) + list(shared["with"])
        let wear: Wardrobe?
        if let text = own["wear"] ?? shared["wear"] {
            guard let parsed = wardrobe(text) else { return .failure(Problem(reason: "bad wear: \(text)")) }
            wear = parsed
        } else {
            wear = nil
        }
        return .success(StyleScene(who: who, setting: setting, details: details,
                                   lighting: own["light"] ?? shared["light"], camera: own["camera"] ?? shared["camera"],
                                   look: own["look"] ?? shared["look"], wear: wear))
    }

    /// `neutral / feminine / masculine`, the last two optional; an empty cut is none.
    static func wardrobe(_ text: String) -> Wardrobe? {
        let cuts = text.components(separatedBy: " / ").map { $0.trimmingCharacters(in: .whitespaces) }
        guard (1...3).contains(cuts.count), !cuts[0].isEmpty else { return nil }
        func cut(_ index: Int) -> String? { index < cuts.count && !cuts[index].isEmpty ? cuts[index] : nil }
        return Wardrobe(neutral: cuts[0], feminine: cut(1), masculine: cut(2))
    }

    /// `|`-separated fields, trimmed.
    static func fields(of line: String) -> [String] {
        line.split(separator: "|", omittingEmptySubsequences: false).map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// `key: value`, when the text starts with a known-looking key.
    static func keyed(_ text: String) -> (String, String)? {
        guard let colon = text.firstIndex(of: ":") else { return nil }
        let key = String(text[..<colon])
        guard !key.isEmpty, key.allSatisfy({ $0.isLowercase && $0.isLetter }) else { return nil }
        let value = text[text.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        return value.isEmpty ? nil : (key, value)
    }

    /// `a; b; c` as a list.
    static func list(_ text: String?) -> [String] {
        (text ?? "").split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    // MARK: Composing

    /// A scene's prompt parts with this subject and wardrobe. The parts
    /// compose (``ImageRecipe/composedPrompt``) in the recipe's fixed order:
    /// subject, details, setting, lighting, camera, style.
    static func prompt(_ scene: StyleScene, subject: String, wear choice: WardrobeChoice) -> ImageRecipe.Prompt {
        let trimmed = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        let who = scene.who.replacingOccurrences(of: StyleScene.subjectSlot,
                                                 with: trimmed.isEmpty ? defaultSubject : trimmed)
        var details: [String] = []
        if let wear = scene.wear, let worn = clothes(wear, choice) { details.append("wearing \(worn)") }
        details += scene.details
        return ImageRecipe.Prompt(subject: who, details: details.isEmpty ? nil : details, setting: scene.setting,
                                  lighting: scene.lighting, camera: scene.camera, style: scene.look)
    }

    /// The cut of a wardrobe to describe; `nil` for ``WardrobeChoice/none``.
    static func clothes(_ wear: Wardrobe, _ choice: WardrobeChoice) -> String? {
        switch choice {
        case .neutral: wear.neutral
        case .feminine: wear.feminine ?? wear.neutral
        case .masculine: wear.masculine ?? wear.neutral
        case .none: nil
        }
    }

    /// The scene a seed picks: seed modulo the number of scenes, so seeds
    /// 7, 8, 9 walk through consecutive scenes.
    static func sceneIndex(seed: UInt32, of count: Int) -> Int {
        count > 0 ? Int(seed % UInt32(count)) : 0
    }
}
