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
//  A style may declare slots before its scenes — `slot: room = living room;
//  kitchen => a kitchen with …` (see StyleSlots.swift) — and use `{room}` in
//  any scene field. A scene's `who` then may lead with a slot instead of
//  `{subject}`; a subject given to such a scene joins its details. Every
//  marker must be declared, and every declared slot used.
//
//  A slot value may carry a tag (`#outdoors`). A scene marked `when:
//  outdoors` is used only while a value in use carries it — and then the
//  general scenes are not — and it takes a style key written `look@outdoors:`
//  (any key, `with` included) over the plain one. Every `when:` and every
//  `key@tag` must name a tag one of the style's slot values carries.
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
        var slots: [StyleSlot] = []

        func close() {
            guard let open = header else { return }
            if scenes.isEmpty { result.problems.append("\(open.name): no scenes") }
            let used = Set(scenes.flatMap(markers))
            for slot in slots where !used.contains(slot.name) {
                result.problems.append("\(open.name): slot \(slot.name) is in no scene")
            }
            let carried = Set(slots.flatMap { $0.known.flatMap { $0.tags ?? [] } })
            let wanted = Set(scenes.compactMap(\.when)).union(shared.keys.compactMap(tag(of:)))
            for tag in wanted.subtracting(carried).sorted() {
                result.problems.append("\(open.name): no slot value carries #\(tag)")
            }
            result.styles.append(ImageStyle(name: open.name, title: open.title, category: open.category, scenes: scenes,
                                            slots: slots))
            header = nil
            shared = [:]
            scenes = []
            slots = []
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
                switch scene(String(line.dropFirst(2)), shared: shared, slots: slots.map(\.name)) {
                case .success(let scene): scenes.append(scene)
                case .failure(let problem): result.problems.append("\(open.name): \(problem.reason)")
                }
            } else if let (key, value) = keyed(line), key == "slot", let open = header {
                switch StyleSlots.parse(value) {
                case .success(let slot) where !slots.contains(where: { $0.name == slot.name }) && scenes.isEmpty:
                    slots.append(slot)
                case .success(let slot):
                    result.problems.append("\(open.name): slot \(slot.name) comes twice or after a scene")
                case .failure(let problem): result.problems.append("\(open.name): \(problem.reason)")
                }
            } else if let (key, value) = keyed(line), keys.contains(base(of: key)), header != nil {
                shared[key] = value
            } else {
                result.problems.append("\(header?.name ?? "?"): cannot read \(line)")
            }
        }
        close()
        return result
    }

    /// The keys a style or a scene may set.
    static let keys: Set<String> = ["look", "light", "camera", "wear", "with", "who", "when"]

    /// `look` of `look@outdoors`.
    static func base(of key: String) -> String {
        key.split(separator: "@", maxSplits: 1).first.map(String.init) ?? key
    }

    /// `outdoors` of `look@outdoors`; `nil` for a plain key.
    static func tag(of key: String) -> String? {
        let parts = key.split(separator: "@", maxSplits: 1)
        return parts.count == 2 ? String(parts[1]) : nil
    }

    struct Problem: Error {
        let reason: String
    }

    /// One scene line: the setting, then `key: value` fields. `slots` are
    /// the style's slot names, which its fields may use as `{name}`.
    static func scene(_ line: String, shared: [String: String], slots: [String] = []) -> Swift.Result<StyleScene, Problem> {
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
        let when = own["when"] ?? shared["when"]
        // A tagged scene takes `key@tag` over the style's plain `key`.
        func inherited(_ key: String) -> String? {
            when.flatMap { shared["\(key)@\($0)"] } ?? shared[key]
        }
        let who = own["who"] ?? inherited("who") ?? StyleScene.subjectSlot
        let whoMarkers = StyleSlots.markers(in: who)
        guard whoMarkers.contains(StyleSlots.subjectName) || whoMarkers.contains(where: slots.contains) else {
            return .failure(Problem(reason: "who: has no \(StyleScene.subjectSlot) in: \(line)"))
        }
        let details = list(own["with"]) + list(inherited("with"))
        let wear: Wardrobe?
        if let text = own["wear"] ?? inherited("wear") {
            guard let parsed = wardrobe(text) else { return .failure(Problem(reason: "bad wear: \(text)")) }
            wear = parsed
        } else {
            wear = nil
        }
        let scene = StyleScene(who: who, setting: setting, details: details,
                               lighting: own["light"] ?? inherited("light"), camera: own["camera"] ?? inherited("camera"),
                               look: own["look"] ?? inherited("look"), wear: wear, when: when)
        let misplaced = texts(of: scene).dropFirst().flatMap(StyleSlots.markers).filter { $0 == StyleSlots.subjectName }
        if !misplaced.isEmpty {
            return .failure(Problem(reason: "\(StyleScene.subjectSlot) belongs in who: only, in: \(line)"))
        }
        if let unknown = markers(scene).first(where: { $0 != StyleSlots.subjectName && !slots.contains($0) }) {
            return .failure(Problem(reason: "{\(unknown)} is not a slot of this style, in: \(line)"))
        }
        return .success(scene)
    }

    /// Every text a scene holds, `who` first.
    static func texts(of scene: StyleScene) -> [String] {
        [scene.who, scene.setting] + scene.details + [scene.lighting, scene.camera, scene.look].compactMap { $0 }
            + [scene.wear?.neutral, scene.wear?.feminine, scene.wear?.masculine].compactMap { $0 }
    }

    /// The names of every `{marker}` a scene uses.
    static func markers(_ scene: StyleScene) -> [String] {
        texts(of: scene).flatMap(StyleSlots.markers)
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
        // `look`, or `look@outdoors`: a lower-case word, optionally tagged.
        let word = { (part: Substring) in !part.isEmpty && part.allSatisfy { $0.isLowercase && $0.isLetter } }
        let parts = key.split(separator: "@", maxSplits: 1, omittingEmptySubsequences: false)
        guard word(parts[0]), parts.count == 1 || StyleSlots.isName(String(parts[1])) else { return nil }
        let value = text[text.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        return value.isEmpty ? nil : (key, value)
    }

    /// `a; b; c` as a list.
    static func list(_ text: String?) -> [String] {
        (text ?? "").split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    // MARK: Composing

    /// A scene's prompt parts with this subject and wardrobe, its slots
    /// filled with `texts` (slot name → the words to put in). The parts
    /// compose (``ImageRecipe/composedPrompt``) in the recipe's fixed order:
    /// subject, details, setting, lighting, camera, style.
    ///
    /// A scene whose `who` leads with a slot rather than `{subject}` — "{room}"
    /// — takes a subject as its first detail when one is given, and no
    /// default subject when not: "a kitchen with …, with a green island, …".
    static func prompt(_ scene: StyleScene, subject: String, wear choice: WardrobeChoice,
                       slots texts: [String: String] = [:]) -> ImageRecipe.Prompt {
        let fill = { (text: String) in StyleSlots.filled(text, with: texts) }
        let trimmed = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        let takesSubject = scene.who.contains(StyleScene.subjectSlot)
        let who = fill(scene.who.replacingOccurrences(of: StyleScene.subjectSlot,
                                                      with: trimmed.isEmpty ? defaultSubject : trimmed))
        var details: [String] = []
        if !takesSubject, !trimmed.isEmpty { details.append(trimmed) }
        if let wear = scene.wear, let worn = clothes(wear, choice) { details.append("wearing \(fill(worn))") }
        details += scene.details.map(fill)
        let setting = fill(scene.setting)
        // A scene that casts the subject — "as a wizard with an oversized hat",
        // "as a marble sculpture" — is a role, not a place: it joins the
        // subject, so the prompt reads "a person as a wizard, wearing a starry
        // robe" rather than putting the role after the clothes.
        let role = isRole(setting)
        return ImageRecipe.Prompt(subject: role ? "\(who) \(setting)" : who,
                                  details: details.isEmpty ? nil : details, setting: role ? nil : setting,
                                  lighting: scene.lighting.map(fill), camera: scene.camera.map(fill),
                                  style: scene.look.map(fill))
    }

    /// Whether a scene's setting casts the subject as something.
    static func isRole(_ setting: String) -> Bool {
        setting.lowercased().hasPrefix("as ")
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
