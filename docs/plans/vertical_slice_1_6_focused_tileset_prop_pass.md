# Vertical Slice 1.6 - Focused Tileset and Prop Production Pass v1

> Status: IMPLEMENTED, headless-verified; needs manual visual acceptance.

## Goal

Replace the most visible placeholder shapes in the existing playable maps with a small
set of reusable, readable visual assets while preserving the current gameplay loop.

This is a visual-production slice, not a systems slice. It should make the shop
exterior, Mapleton Lane, Forest Clearing, and Forest Path feel warmer and more
intentional at 640x360 without adding new quests, mechanics, NPCs, schedules, or map
regions.

## Why This Comes Next

Vertical Slice 1.5 clarified the blockouts and important routes. The next useful step is
to make those settled layouts feel more handcrafted before expanding the game again.

Small art passes now will make later planter, shop-display, and ambient-town slices feel
better without pulling in full tileset tooling or decoration systems.

## Required Scope

### General Rules

- Keep every change tied to an existing playable scene.
- Prioritize readable silhouettes over dense decoration.
- Use small reusable image assets or scene-local visual nodes; do not create a broad
  decoration system.
- Preserve all existing collision, transition, quest, gathering, shop, dialogue, save,
  and Saffron behavior.
- Keep placeholder art acceptable where it is not distracting.
- Do not edit user-supplied humanoid character art.
- If creating or replacing destructive art files, snapshot affected originals to
  `backups/` first.

### Shop Exterior

Focus:

- Shop facade readability.
- Front step/path/threshold.
- Lantern/mailbox/sign-like prop clarity.
- Future planter/garden marker visual polish while keeping it non-interactive.

Non-goals:

- Planting mechanics.
- Shop exterior expansion.
- Interior shop art overhaul.

### Mapleton Lane

Focus:

- Notice board readability.
- Camellia restaurant stall silhouette.
- Sage plant-stall silhouette.
- Fences, shrubs, and path-edge details that support the current blockout.

Non-goals:

- New town districts.
- New NPCs.
- NPC schedules or ambient dialogue.
- Shop/restaurant interiors.

### Forest Clearing

Focus:

- Gatherable silhouettes remain clear.
- Ground/path detail supports the existing route.
- Shop return and forest path exit remain visually obvious.
- Existing forest art assets can be reused or lightly supplemented.

Non-goals:

- New gatherables.
- New forest regions.
- Weather, enemies, stamina, or tools.

### Forest Path

Focus:

- Brook, brook banks, thickets, and compact trail readability.
- Brookmint patches remain easy to spot.
- Return route to Forest Clearing remains obvious.

Non-goals:

- More exits.
- Larger forest region.
- New ingredients.

## Suggested Files

Likely touched:

```text
art/backgrounds/
art/props/
scenes/world/ShopExterior.tscn
scenes/world/MapletonLane.tscn
scenes/world/ForestClearing.tscn
scenes/world/ForestPath.tscn
tools/verify_vertical_slice_1_6.gd
docs/PROGRESS.md
```

Optional only if useful:

```text
docs/plans/vertical_slice_roadmap.md
```

## Implementation Order

1. Run focused verifiers for 0.6 through 1.5 before editing.
2. Inventory the existing placeholder shapes and reusable art assets in the four target
   maps.
3. Decide the smallest asset set that improves readability across multiple scenes.
4. Add or replace visual assets one scene at a time.
5. Keep collision and interaction nodes stable unless a visual asset reveals a specific
   alignment bug.
6. Add `tools/verify_vertical_slice_1_6.gd` for scene loading and preservation checks.
7. Run focused verifiers for affected systems.
8. Play manually at 640x360 and check that text/prompts, interactables, exits, and
   gatherables remain readable.
9. Update `docs/PROGRESS.md` and this plan with implementation notes.

## Implementation Notes

- Added small deterministic PNG prop sprites instead of introducing broad tileset or
  decoration tooling.
- New shop exterior sprites cover the witch-shop facade, front step, crates, shrub,
  polished future planter marker, lantern, mailbox, and fence runs.
- New Mapleton Lane sprites cover the notice board, Camellia restaurant stall, Sage
  plant stall, fence runs, and shrub-bank edges.
- Forest Clearing keeps its existing background and gatherables, with a clearer
  forest-path gate sprite layered onto the existing quest-locked door.
- Forest Path now uses sprite-backed Brookmint patches, thicket sprites, and subtle
  brook sparkle cues.
- Existing collision, door metadata, gatherable IDs, NPC nodes, Saffron placement, quest
  locks, and the visual-only planter marker were preserved.
- No user-supplied humanoid character art was edited.

## Verification Plan

Add `tools/verify_vertical_slice_1_6.gd`.

The verifier should check:

- The four target scenes load.
- Existing Player and Cat nodes remain present.
- Existing transition doors still target the same scenes and arrival positions.
- Existing boundary collision nodes remain present.
- Mapleton Lane still has `NoticeBoard`, `Camellia`, and `Sage`.
- Forest Clearing still has Moonleaf, Forest Water, Dewcap, Glowberry, and
  `ForestPathDoor`.
- Forest Path still has two Brookmint patches and a return door.
- ShopExterior still has `FuturePlanterMarker`, and it remains visual-only.
- Any new art resource paths used by target scenes exist and import.

The verifier should not judge beauty; final visual acceptance is manual.

## Verification Results

Headless focused verifiers passed after implementation:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_0_8.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_0.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_3.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_4.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_5.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_6.gd
```

The new PNG assets were imported by running the headless editor and waiting for the
import scan before stopping the process.

## Manual Acceptance Test

1. Open `scenes/ui/TitleMenu.tscn` and press Play.
2. Walk from the shop to the shop exterior.
3. Confirm the facade, front path, lane exit, shop return, and future planter marker are
   clearer than before.
4. Walk to Mapleton Lane.
5. Confirm the notice board, restaurant stall, plant stall, path edges, and blocked
   boundaries read well at 640x360.
6. Walk to the forest clearing.
7. Confirm gatherables, the shop return, and forest path exit remain obvious.
8. Walk to Forest Path.
9. Confirm Brookmint, brook edges, thickets, trail, and return direction remain clear.
10. Confirm existing quest, board, NPC, gathering, cauldron, shop, dialogue portrait,
    save/load, and Saffron behavior are unchanged.

## Non-Goals

- New mechanics.
- New quests, recipes, ingredients, NPCs, or areas.
- NPC presence/schedule system.
- Full town map.
- Full decoration system.
- Freeform building/decorating.
- Large all-purpose tileset tooling.
- Weather, seasons, farming, combat, stamina, or economy changes.
- Reworking user-supplied humanoid character art.

## Deferred Note

The current Sage shop/lane duplication risk should eventually be solved with a small NPC
presence/schedule system that derives where each NPC belongs from day, quest state, and
authored rules. That is not part of 1.6 unless it blocks the visual pass.
