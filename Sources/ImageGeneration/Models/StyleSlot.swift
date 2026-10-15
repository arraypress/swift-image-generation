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
//  phrase ("kitchen" → "a kitchen with fitted cabinets, …"), answer to
//  aliases ("garden" → "outdoor garden") and carry tags ("outdoors") that
//  choose the style's scenes and wording for that kind of value. Any other
//  value goes into the prompt as typed.
//
//  The type is RecipeKit's, shared with song's styles; `text(for:)` and
//  `value(named:)` come with it.
//

import RecipeKit

/// A gap in a style's scenes, written `{name}`, and what may fill it.
public typealias StyleSlot = RecipeKit.StyleSlot
