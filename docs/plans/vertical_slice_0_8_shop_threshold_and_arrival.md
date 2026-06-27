# Vertical Slice 0.8 - Shop Threshold and Arrival v1

> Status: IMPLEMENTED.
> Start after Vertical Slice 0.7 is committed or otherwise safely backed up.

## Goal

Give Marigold her first tiny step outside the shop without opening the full village
scope. The player should be able to leave through the shop's front door, stand in a
small exterior threshold scene, and re-enter the shop. This makes Mapleton feel less
sealed off while preserving the current shop, forest, bedroom, quest, and browsing
customer loops.

This slice is deliberately not a village map. It is a small transition space that proves
the front door can become a player-facing route while still serving as the visitor
entrance for Sage, Camellia, and browsing customers.

## Player Flow

1. Start in Marigold's shop.
2. Walk to the front door.
3. Interact and transition outside.
4. Arrive on the front step of Marigold's shop.
5. See a tiny shop exterior/threshold with blocked paths toward town.
6. Walk around the small threshold area.
7. Re-enter the shop through the front door.
8. Confirm Saffron follows through both transitions.
9. Confirm Sage, Camellia, and the generic customer still use the shop's interior front
   entrance route correctly.
10. Sleep, save, quit, Continue, and confirm an exterior save restores the exterior
    scene and player position.

## Required Scope

### New exterior scene

- Add `scenes/world/ShopExterior.tscn`.
- Keep it compact and temporary; suggested first-pass footprint is around `640x360` or
  `720x480`, matching the current internal resolution and shop scale.
- Include:
  - simple ground/path placeholder art;
  - a visible shop facade or labelled placeholder;
  - a front step/door return point;
  - boundary collision so Marigold cannot leave the tiny area;
  - one or two small props such as a sign, mailbox, fence, shrubs, crates, lanterns, or
    a path marker.
- Use placeholder rectangles/simple pixel props if no focused art exists yet.
- Do not spend this slice on a polished exterior art pass.

### Door transitions

- Update the `FrontDoor` in `scenes/world/ShopInterior.tscn` so the player can transition
  to `res://scenes/world/ShopExterior.tscn`.
- Add an exterior return door/interactable that transitions back to
  `res://scenes/world/ShopInterior.tscn`.
- Set explicit `target_player_position` and `target_player_facing` values in both
  directions.
- Preserve the existing `VisitorEntrance` and `VisitorInteriorWaypoint` markers; Sage,
  Camellia, and the generic customer should continue to use those markers for their
  internal scripted routes.

### Companion transition

- Confirm Saffron appears behind Marigold when moving:
  - shop -> exterior;
  - exterior -> shop.
- If the cat appears at a scene default position instead of near Marigold, fix the
  smallest transition-state issue in `scripts/npc/CatCompanion.gd` or door metadata.

### Save/load

- Reuse the existing save shape: `current_scene` and `player_position` should already be
  enough.
- Verify saving while outside restores the exterior scene and Marigold's position on
  Continue.
- Do not bump the save version unless the implementation changes save data shape.

### Camera and collision

- Add camera limits suitable for the exterior footprint.
- Add simple collision around scene edges and the shop facade.
- Keep collision readable and forgiving; no decorative collision maze.

### Verification

- Add `tools/verify_vertical_slice_0_8.gd`.
- The verifier should check:
  - `ShopExterior.tscn` exists and loads;
  - shop `FrontDoor` targets the exterior;
  - exterior return door targets `ShopInterior.tscn`;
  - target positions/facings are set in both directions;
  - the exterior has a player, camera, Saffron, and boundary collision;
  - saving/restoring an exterior scene path remains compatible with `SaveSystem`;
  - existing 0.7 quest data and visitor nodes still load.

## Implementation Order

1. Run the 0.7 verifier and do a quick manual smoke test if needed.
2. Create `ShopExterior.tscn` with placeholder ground, facade, collision, player, camera,
   Saffron, and return door.
3. Wire shop `FrontDoor` to the exterior with explicit arrival position/facing.
4. Wire exterior return door back to the shop with explicit arrival position/facing.
5. Tune camera limits and collision.
6. Verify Saffron transition placement in both directions.
7. Verify save/continue from the exterior.
8. Add `tools/verify_vertical_slice_0_8.gd`.
9. Run 0.6, 0.7, and 0.8 focused verifiers.
10. Update `docs/PROGRESS.md` and this plan with implementation notes.

## Acceptance Test

1. Start a new game.
2. In the shop, walk to the front door and interact.
3. Confirm Marigold appears outside on the front step, facing away from the door.
4. Confirm Saffron appears behind/near Marigold rather than at an unrelated default
   position.
5. Walk the exterior threshold and confirm boundary collision blocks the unfinished
   village paths.
6. Interact with the exterior door and return to the shop.
7. Confirm Marigold appears just inside the front door and Saffron follows.
8. Complete or load into Sage/Camellia/customer situations and confirm visitors still
   enter through the internal front-door route.
9. Save while outside, quit, Continue, and confirm the exterior scene and player position
   restore correctly.
10. Run the existing 0.6 and 0.7 verifiers to confirm earlier loops still load.

## Non-Goals

- Full village map.
- Shop exterior polish pass or final facade art.
- Restaurant, plant shop, or other building exteriors.
- NPC schedules, wandering villagers, ambient town dialogue, or pathfinding.
- New quests, new recipes, new items, or new gathering nodes.
- Calendar, time blocks, seasons, or weather.
- Farming, mailbox mail, shop upgrades, town reputation, or relationship systems.
- Changing visitor/customer routing beyond preserving the existing front-door markers.

## Risks

- The shop front door currently doubles as a player-facing future door and as the visual
  source for visitor entrances. Keep scripted visitor markers separate from player door
  transition logic.
- Saffron's behind-player transition depends on scene metadata and target facing. Test
  both directions before expanding the exterior.
- A tiny exterior can easily invite village scope creep. Keep every blocked path as a
  visible promise for later, not a new area in this slice.

## Success Criteria

- The player can leave and re-enter the shop through the front door.
- The exterior threshold is readable, bounded, and save/load compatible.
- Saffron follows correctly.
- Existing 0.1-0.7 shop, quest, crafting, customer, and visitor flows remain intact.

## Implementation Notes

- Added `scenes/world/ShopExterior.tscn`, a compact 720x480 placeholder threshold with
  a shop facade, front step, blocked path hints, simple props, boundary collision,
  Marigold, camera limits, Saffron, and a return door.
- The shop `FrontDoor` now sends the player to the exterior at `Vector2(360, 230)`,
  facing south. The exterior `ReturnDoor` sends the player back just inside the shop
  front door at `Vector2(360, 420)`, facing north.
- The existing `VisitorEntrance` and `VisitorInteriorWaypoint` markers were not moved;
  Sage, Camellia, and the browsing customer still use those interior markers.
- Added `tools/verify_vertical_slice_0_8.gd` to check scene wiring, visitor marker
  preservation, Saffron's transition placement, camera/collision basics, and
  SaveSystem current-scene/player-position compatibility for the exterior.
