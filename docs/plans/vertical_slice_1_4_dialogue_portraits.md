# Vertical Slice 1.4 - Dialogue Portraits v1

> Status: IMPLEMENTED and headless-verified on 2026-07-01.
> Manual acceptance in the Godot editor is still recommended.

## Goal

Let the existing dialogue box show a larger character portrait for speakers that
already have user-supplied portrait art, while preserving the current simple dialogue
API and all existing quest/shop dialogue flows.

This is a visual-support slice, not a dialogue-system slice. It makes repeated Sage,
Camellia, and Marigold dialogue feel more personal without adding branching dialogue,
relationship UI, expression data, or a full NPC database.

## Implemented Scope

- Added a larger lower-left portrait/nameplate layout to `scenes/ui/DialogueBox.tscn`,
  inspired by classic pixel RPG dialogue layouts.
- Follow-up feedback adjusted the layout so Marigold's portrait/nameplate appears on
  the lower-right, while NPC portraits stay on the lower-left.
- Fixed portrait/nameplate cleanup so they hide when the dialogue closes.
- Added a tiny speaker-name and expression lookup in `scripts/ui/DialogueBox.gd`.
- Mapped existing default portraits:
  - `Marigold` -> `art/characters/marigold/portraits/default.png`
  - `Sage` -> `art/characters/npcs/sage/portraits/default.png`
  - `Camellia` -> `art/characters/npcs/camellia/portraits/default.png`
- Mapped existing expression portraits such as `thinking`, `concerned`, `laugh`, and
  `blushed` where the files exist.
- Kept `DialogueBox.show_dialogue(speaker, lines)` unchanged for existing string arrays.
- Added optional per-line dialogue dictionaries with `speaker`, `expression`, and `text`.
- Added a few Marigold replies to Sage/Camellia quest conversations so the portrait can
  naturally switch speakers.
- Hid the portrait slot for speakers without portrait art, such as `Notice Board` and
  `Villager`.
- Added `tools/verify_vertical_slice_1_4.gd`.

## Non-Goals

- New portrait art.
- Cropping, resizing, recoloring, or repainting existing portrait exports.
- Full expression matrices or emotion-selection tooling.
- Relationship UI.
- Branching conversation systems.
- Visual novel cutscenes.
- Full dialogue database rewrite.
- NPC database migration.

## Verification

Run:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_4.gd
```

The verifier checks:

- DialogueBox has stable portrait UI nodes and dimensions.
- Marigold, Sage, and Camellia map to their existing default portrait files.
- Expression-specific portrait paths resolve and missing expressions fall back to
  default.
- Notice Board and Villager use the no-portrait fallback.
- Portrait textures load when dialogue opens.
- Dialogue can switch speaker/expression per line, still advances through multiple lines,
  and closes after the last line.

## Manual Acceptance Test

1. Start or continue the game.
2. Trigger Marigold dialogue by interacting with the locked forest path before Sage's
   restock quest is complete.
3. Talk to Sage or Camellia during any active quest/delivery.
4. Confirm NPC portraits appear at the lower-left with a nameplate.
5. Advance through a conversation with Marigold replies and confirm the portrait switches
   speaker/expression and Marigold appears on the lower-right.
6. Read the Mapleton Lane notice board or serve a generic customer.
7. Confirm the dialogue box cleanly hides the portrait slot for no-portrait speakers.
8. Advance through several dialogue lines and confirm input/closing behavior is unchanged,
   including the portrait/nameplate disappearing after the last line.

## Notes

- Existing portrait exports are 140x140 PNGs. They are scaled only at display time; the
  source PNGs are not edited.
- Generic customer and Saffron portraits can be wired later once user-supplied portrait
  art exists.
