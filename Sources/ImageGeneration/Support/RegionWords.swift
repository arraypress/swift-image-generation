//
//  RegionWords.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Other words for the thing a mask is asked for. SAM 3 is picky about
//  wording, measured on generated fashion photos (scores, 0–1; 0.6 passes):
//  a grey crew-neck t-shirt scored < 0.6 as "t-shirt" but 0.99 as "tshirt"
//  and 0.92 as "top"; a navy blazer 0.40 as "jacket" and 0.97 as "blazer".
//  So a name that matches nothing is tried again as the words people use
//  for the same thing — the caller keeps the best that passes, and says
//  which. Each group is in the order the words are worth trying.
//

import Foundation

enum RegionWords {

    /// Groups of words for one kind of thing, best first. A word may sit in
    /// more than one group ("top" names a t-shirt and a sweater alike).
    static let groups: [[String]] = [
        ["tshirt", "top", "shirt", "t-shirt", "tee", "blouse"],
        ["sweater", "jumper", "top", "hoodie", "sweatshirt", "cardigan"],
        ["blazer", "jacket", "coat", "suit jacket"],
        ["trousers", "pants", "jeans", "slacks", "chinos"],
        ["jeans", "trousers", "pants", "denim"],
        ["shorts", "trousers", "pants"],
        ["dress", "gown", "skirt"],
        ["skirt", "dress"],
        ["shoes", "sneakers", "trainers", "boots", "footwear"],
        ["hat", "cap", "beanie"],
        ["arm", "arms", "sleeve"],
        ["glasses", "spectacles", "eyeglasses", "sunglasses"],
    ]

    /// Spellings that mean one of the words above.
    static let spellings: [String: String] = [
        "t shirt": "tshirt", "tees": "tee", "tshirts": "tshirt", "t-shirts": "tshirt",
        "sneaker": "sneakers", "trainer": "trainers", "boot": "boots", "shoe": "shoes",
        "jumpers": "jumper", "sweaters": "sweater", "hoodies": "hoodie", "jackets": "jacket",
        "blazers": "blazer", "coats": "coat", "dresses": "dress", "skirts": "skirt",
        "trouser": "trousers", "pant": "pants", "hats": "hat", "caps": "cap",
    ]

    /// `word` as compared: lower-cased, trimmed, inner spaces collapsed.
    static func key(_ word: String) -> String {
        let lowered = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let collapsed = lowered.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        return spellings[collapsed] ?? collapsed
    }

    /// The words to try for `word`: the word itself first, as typed, then the
    /// other words of every group it belongs to, each once. A word in no
    /// group has no others.
    static func candidates(for word: String) -> [String] {
        let typed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !typed.isEmpty else { return [] }
        let wanted = key(typed)
        var out = [typed], seen: Set<String> = [key(typed)]
        for group in groups where group.contains(wanted) {
            for other in group where seen.insert(key(other)).inserted { out.append(other) }
        }
        return out
    }
}

extension RegionWords {

    /// Which word to use, from each candidate's best score in the order
    /// tried: the first (the word as typed) whenever it reaches `minimum`,
    /// else the highest-scoring other word that does; `nil` when none does —
    /// never a word below the floor.
    static func choose(_ scored: [(word: String, score: Double)], minimum: Double) -> String? {
        guard let first = scored.first else { return nil }
        if first.score >= minimum { return first.word }
        return scored.dropFirst().filter { $0.score >= minimum }.max { $0.score < $1.score }?.word
    }
}
