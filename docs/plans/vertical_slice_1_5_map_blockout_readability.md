# Vertical Slice 1.5 - Map Blockout and Layout Readability v1

> Status: IMPLEMENTED, HEADLESS-VERIFIED.
> Manual visual acceptance pending.

## Goal

Make the currently playable spaces easier to read at the real 640x360 game scale before
spending time on polished tilesets and props.

This is a layout and readability slice, not a content slice. It should clarify where
Marigold can walk, where each exit leads, where important NPCs and interactables sit,
and where a future tiny planter or garden corner could belong. It should not add new
items, recipes, quests, NPCs, map regions, farming mechanics, or shop systems.

## Implementation Notes

Implemented on 2026-07-02.

- `ShopExterior` now has clearer path edges, a more obvious lane mouth, and a
  visual-only `FuturePlanterMarker` on the shop property.
- `MapletonLane` now has stronger lane/path edge cues and approach patches around the
  notice board, Camellia's restaurant stall, and Sage's plant stall.
- `ForestClearing` now has subtle visual route cues for the shop return and the deeper
  forest path exit.
- `ForestPath` now has clearer return-route, trail-edge, brook-bank, and blocked-thicket
  cues around the Brookmint patches.
- `tools/verify_vertical_slice_1_5.gd` verifies scene loading, transition wiring,
  boundary collision nodes, key NPC/interactable/gatherable presence, camera limits
  where expected, Saffron transition metadata, and that `FuturePlanterMarker` remains
  visual-only.
- Post-change headless checks passed for every focused verifier from 0.6 through 1.5.

## Why This Comes Next

Vertical Slice 1.3 added the first quest-gated forest expansion, and Vertical Slice 1.4
made conversations feel more intentional with portraits. The next weakest layer is the
world staging: the compact screens work, but they still use placeholder shapes and could
benefit from a deliberate visual language before more art or mechanics land on top.

Doing this now makes later tileset, prop, and planter work less wasteful. The maps do
not need final art yet, but their playable composition should feel settled.

## Player Flow

1. Start in the shop.
2. Walk from the shop front door to `ShopExterior`.
3. Confirm the front path, lane path, shop return, and future planter/garden area are
   visually understandable.
4. Walk from `ShopExterior` to `MapletonLane` and back.
5. Confirm the notice board, Camellia restaurant stall, Sage plant stall, and lane return
   point are readable without feeling crowded.
6. Walk from the shop to `ForestClearing`.
7. Confirm the shop return and `ForestPath` exit are visually clear.
8. Walk to `ForestPath`, gather Brookmint, and return.
9. Confirm Saffron appears behind Marigold across each transition.
10. Confirm existing quest, board, NPC, gathering, cauldron, shop, and dialogue flows are
    unchanged.

## Required Scope

### General Layout Rules

- Keep each scene compact and bounded.
- Prefer small placeholder ground/path shapes, fences, signs, shrubs, steps, and blocked
  edges over new systems.
- Make walkable paths visually distinct from blocked edges.
- Keep important interactables in open space with comfortable approach room.
- Keep camera limits and collision bounds explicit.
- Keep all changes scene-local unless a tiny verifier helper is needed.
- Do not introduce tutorial text, map UI, or new gameplay prompts unless an existing
  prompt label already belongs to the interactable.

### Shop Exterior

Review and lightly revise `scenes/world/ShopExterior.tscn`.

The scene should clearly show:

- the shop facade and front door back into the shop;
- the path from the shop door toward Mapleton Lane;
- the lane transition;
- blocked side edges;
- Saffron's arrival placement;
- a small inactive future planter or garden corner marker.

The future planter marker should be visual only. It should not use an interaction area,
planting script, seed consumption, growth state, save data, or harvest behavior.

Recommended default: place the future planter/garden hint on the shop property in
`ShopExterior`, where it can later pay off Sage's Moonleaf Seed Packet without moving
the home layout again.

### Mapleton Lane

Review and lightly revise `scenes/world/MapletonLane.tscn`.

The scene should clearly show:

- the return path back to the shop exterior;
- the main lane path and cross path;
- the notice board as an important interactable;
- Camellia by the restaurant stall;
- Sage by the plant stall;
- enough approach room around the board and both NPCs.

Keep the lane as one bounded screen. Do not add town districts, interiors, schedules, a
board menu, or more NPCs.

### Forest Clearing

Review and lightly revise `scenes/world/ForestClearing.tscn`.

The scene should clearly show:

- the return door/path back to the shop;
- existing gatherables;
- the locked/unlocked `ForestPathDoor`;
- the idea that the forest path is a route deeper into the woods.

Do not add new forest areas, ingredients, gathering rules, enemies, stamina, tools, or
weather.

### Forest Path

Review and lightly revise `scenes/world/ForestPath.tscn`.

The scene should clearly show:

- the return route to `ForestClearing`;
- the compact walking path;
- the brook/greenery theme;
- the two Brookmint patches;
- blocked thicket edges.

Do not expand the path into a larger region or add more exits.

### Shop Interior Check

Avoid changing `scenes/world/ShopInterior.tscn` unless the implementation discovers a
specific transition or arrival readability problem.

If touched, keep the change limited to preserving:

- the front visitor door;
- the forest door;
- the room door;
- counter/customer flow;
- display stocking flow;
- Sage/customer counter waiting positions.

## Suggested Files

Likely touched during implementation:

```text
docs/plans/vertical_slice_1_5_map_blockout_readability.md
scenes/world/ShopExterior.tscn
scenes/world/MapletonLane.tscn
scenes/world/ForestClearing.tscn
scenes/world/ForestPath.tscn
tools/verify_vertical_slice_1_5.gd
docs/PROGRESS.md
```

Optional only if a tiny reusable placeholder helper becomes genuinely useful:

```text
scripts/core/ReadabilityMarker.gd
```

Prefer not adding that script unless duplicated placeholder behavior becomes annoying.

## Implementation Order

1. Run the focused 0.6-1.4 verifiers before editing, or at least the layout-heavy
   verifiers for 0.8, 1.0, 1.3, and 1.4.
2. Inspect the four target scenes and list their existing transition, camera, collision,
   NPC, and gatherable nodes.
3. Make a small `ShopExterior` readability pass, including the inactive future
   planter/garden marker.
4. Make a small `MapletonLane` readability pass around the lane paths, board, Camellia,
   and Sage.
5. Make a small `ForestClearing` readability pass around the shop return and forest path
   exit.
6. Make a small `ForestPath` readability pass around the brook, thickets, Brookmint
   patches, and return route.
7. Add `tools/verify_vertical_slice_1_5.gd`.
8. Run focused 0.6-1.5 verifiers.
9. Walk the scenes manually in Godot at the real game scale.
10. Update `docs/PROGRESS.md` and this plan with implementation notes.

## Verification Plan

Add `tools/verify_vertical_slice_1_5.gd`.

The verifier should check:

- `ShopExterior.tscn`, `MapletonLane.tscn`, `ForestClearing.tscn`, and
  `ForestPath.tscn` load.
- Each scene still has a `Player` and `Cat` where expected.
- Camera limits remain present on exterior, lane, and forest path scenes.
- Each scene still has explicit boundary collision nodes.
- `ShopExterior` has `ReturnDoor` targeting the shop and `LaneDoor` targeting
  Mapleton Lane.
- `MapletonLane` has `ReturnDoor` targeting the shop exterior.
- `ForestClearing` has the normal shop return door and the quest-locked
  `ForestPathDoor`.
- `ForestPath` has `ReturnDoor` targeting the forest clearing.
- Saffron transition metadata still exists for all updated doors.
- `MapletonLane` still has `NoticeBoard`, `Camellia`, and `Sage`.
- `ForestClearing` still has the existing Moonleaf, Forest Water, Dewcap, and Glowberry
  gatherables.
- `ForestPath` still has two Brookmint patches.
- The future planter/garden marker exists in `ShopExterior` and is visual-only.

The verifier should not attempt to judge beauty. Visual clarity should be accepted
manually in Godot.

## Manual Acceptance Test

1. Open `scenes/ui/TitleMenu.tscn` and press Play.
2. Start or continue into the shop.
3. Walk through the shop front door.
4. Confirm the shop exterior reads as a small threshold with a clear shop return, lane
   path, blocked edges, and inactive future planter/garden corner.
5. Walk to Mapleton Lane and back.
6. Confirm the board, Camellia, Sage, restaurant stall, plant stall, return path, and
   collision edges are easy to parse at 640x360.
7. Walk to the forest clearing.
8. Confirm gatherables, the shop return, and the forest path exit are easy to parse.
9. Walk to the forest path and back.
10. Confirm Brookmint patches, thickets, brook/path shapes, and return direction are easy
    to parse.
11. Confirm Saffron follows through each transition and appears behind Marigold.
12. Confirm existing quest, board, NPC, gathering, cauldron, shop, dialogue portrait, and
    save/load flows still work.

## Non-Goals

- Full village map.
- New town districts.
- New forest regions.
- New interiors.
- New quests, recipes, ingredients, NPCs, or dialogue.
- Farming mechanics.
- Using or consuming the Moonleaf Seed Packet.
- Minimap or map UI.
- NPC schedules.
- Decoration mode.
- Final tileset or prop art production.
- Large scene rewrites.
- New save data.
