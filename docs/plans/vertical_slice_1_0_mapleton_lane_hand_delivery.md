# Vertical Slice 1.0 - Mapleton Lane and First Hand Delivery v1

> Status: IMPLEMENTED, headless-verified, and manually accepted on 2026-06-27.

## Goal

Add the smallest real piece of Mapleton beyond the shop doorstep and use it to support
one in-person delivery request.

This slice should pay off the parked posted-request idea without adding a full village,
NPC schedules, a request board system, or anonymous mailbox turn-ins. The important
fantasy is simple: Marigold sees a local request, crafts the item, walks into town, and
hands it to the requester face to face.

## Why This Comes Next

Vertical Slice 0.8 added the shop exterior threshold. Vertical Slice 0.9 made sellable
crafted goods and Glowberry Cordial matter in normal shop play. The next smallest step is
to create one tiny town lane that lets requests end with direct delivery.

This is not the full village milestone. It is a narrow bridge from the home/shop loop to
the future town loop.

## Player Flow

1. Complete `camellia_first_request` and learn Glowberry Cordial.
2. Sleep to the next day.
3. Leave the shop to `ShopExterior`.
4. Walk from the shop threshold into a small `MapletonLane` scene.
5. Read a notice board with one request from Camellia.
6. Accept `camellia_cordial_delivery`.
7. Craft or carry `glowberry_cordial` x2.
8. Return to Mapleton Lane.
9. Talk to Camellia at a restaurant doorway or simple stall.
10. Hand over the cordials in person.
11. Receive gold and a short thank-you.
12. Sleep/save/continue and confirm the completed request persists.

## Required Scope

### Mapleton Lane

- Add one compact scene: `scenes/world/MapletonLane.tscn`.
- Keep it bounded and small, approximately the same 720x480 footprint as the current
  shop exterior.
- Include:
  - player spawn;
  - Saffron spawn;
  - collision boundaries;
  - a return transition to `ShopExterior`;
  - a simple notice board;
  - a simple restaurant doorway/stall area for Camellia.
- Use placeholder shapes/colours first. Do not spend time on polished town art in this
  slice.
- Keep the lane as a single authored screen. Do not add a scrollable town map yet.

### Transitions

- Add one door/edge transition from `ShopExterior.tscn` to `MapletonLane.tscn`.
- Add one return transition from `MapletonLane.tscn` to `ShopExterior.tscn`.
- Use explicit `target_player_position` and `target_player_facing` like the 0.8 exterior
  work.
- Confirm Saffron follows through both transitions.
- Confirm `SaveSystem` can save/continue from `MapletonLane`.

### Notice Board

- Add one focused interactable, suggested script:
  `scripts/core/NoticeBoard.gd`.
- The board should only expose one request in this slice:
  `camellia_cordial_delivery`.
- If the request is not available, show a short dialogue/toast.
- If available and not started, show a short board text and start the quest.
- If already active/ready, remind the player to deliver the cordials to Camellia.
- If completed, show a completed/empty message.
- Do not build a menu, request list, repeatable board, filtering, timers, reputation, or
  request database yet.

### Delivery Quest

- Add one quest entry to `data/quests.json`:

```json
{
  "id": "camellia_cordial_delivery",
  "title": "A Cordial Delivery",
  "npc_name": "Camellia",
  "turn_in_item_id": "glowberry_cordial",
  "turn_in_quantity": 2,
  "reward_gold": 60,
  "reward_items": {},
  "reward_recipes": [],
  "required_quests": ["camellia_first_request"],
  "minimum_day": 3
}
```

- Use the existing `QuestSystem` state flow:
  `not_started -> active -> ready_to_turn_in -> completed`.
- Let the existing HUD tracker show the active/ready objective.
- Reward only gold for this slice. Do not add a new recipe, item, relationship point, or
  restaurant system as a reward.
- If `minimum_day: 3` feels too slow during manual testing, it is acceptable to set it to
  `2`, but keep the request gated behind completed `camellia_first_request`.

### Camellia Delivery NPC

- Reuse existing Camellia art and movement resource. Do not edit, resize, recolour, or
  regenerate the user-supplied character frames.
- Prefer a small new lane-specific script over expanding the existing shop-visitor script
  into a generic framework. Suggested file:
  `scripts/npc/CamelliaLaneNPC.gd`.
- Camellia can stand still at the restaurant doorway/stall for this slice.
- Interaction behavior:
  - if `camellia_cordial_delivery` is not started, mention the notice board;
  - if active but missing items, remind Marigold about Glowberry Cordial x2;
  - if ready, complete the quest, remove the items, award gold, and show thank-you lines;
  - if completed, show a short friendly line.
- Do not add schedules, restaurant interior gameplay, cafe systems, friendship, portraits,
  or multiple Camellia states outside this request.

## Suggested Files

```text
docs/plans/vertical_slice_1_0_mapleton_lane_hand_delivery.md
data/quests.json
scenes/world/ShopExterior.tscn
scenes/world/MapletonLane.tscn
scripts/core/NoticeBoard.gd
scripts/npc/CamelliaLaneNPC.gd
tools/verify_vertical_slice_1_0.gd
docs/PROGRESS.md
```

Use existing files where possible:

```text
scenes/world/Door.tscn
scenes/player/Player.tscn
scenes/npc/Cat.tscn
scenes/npc/Camellia.tscn or Camellia sprite frames
scripts/core/Interactable.gd
scripts/systems/QuestSystem.gd
scripts/systems/QuestDatabase.gd
scripts/systems/SaveSystem.gd
scripts/ui/HUD.gd
```

## Implementation Order

1. Run focused 0.6, 0.7, 0.8, and 0.9 verifiers before editing.
2. Add `MapletonLane.tscn` with placeholder ground, boundaries, player, camera, Saffron,
   return door, board, and Camellia marker.
3. Wire `ShopExterior.tscn` to the lane and back with explicit spawn positions.
4. Add the `camellia_cordial_delivery` quest data.
5. Add `NoticeBoard.gd` to start/remind the one request.
6. Add a lane-specific Camellia interaction script for in-person delivery.
7. Confirm HUD tracker text is acceptable using existing quest objective logic.
8. Add `tools/verify_vertical_slice_1_0.gd`.
9. Run 0.6, 0.7, 0.8, 0.9, and 1.0 focused verifiers.
10. Update `docs/PROGRESS.md` and this plan with implementation notes.

## Verification

Add `tools/verify_vertical_slice_1_0.gd`.

The verifier should check:

- `MapletonLane.tscn` loads.
- It has `Player`, `Player/Camera2D`, `Cat`, boundary collisions, a notice board, and a
  Camellia delivery NPC/interaction area.
- `ShopExterior` has a transition to `MapletonLane`.
- `MapletonLane` has a return transition to `ShopExterior`.
- Both transitions use explicit target player positions and facings.
- `SaveSystem` reports `MapletonLane.tscn` as the current scene and can capture the lane
  player position.
- `QuestDatabase` loads `camellia_cordial_delivery`.
- The quest is unavailable before `camellia_first_request` is completed.
- The notice board can start the quest once gates are satisfied.
- Adding `glowberry_cordial` x2 moves the quest to ready.
- Camellia can complete the quest, remove exactly two cordials, and award the configured
  gold.
- The completed quest state survives `QuestSystem.get_save_data()` / `load_from()`.
- Saffron placement after shop exterior <-> lane transitions is close enough to Marigold.

## Acceptance Test

1. Start from a save where `camellia_first_request` is complete, or complete it manually.
2. Sleep to Day 3 if the quest uses `minimum_day: 3`.
3. Leave the shop to the exterior.
4. Walk to the Mapleton Lane transition.
5. Read the notice board and accept **A Cordial Delivery**.
6. Craft or carry `Glowberry Cordial x2`.
7. Return to Mapleton Lane and talk to Camellia at the restaurant doorway/stall.
8. Confirm the cordials are removed, gold increases by the reward, and the quest completes.
9. Sleep/save/continue and confirm the quest stays completed.
10. Confirm the shop exterior, Saffron follow, and existing shop/quest loops still work.

## Non-Goals

- Full village map.
- More than one town screen.
- Restaurant interior.
- New NPCs besides reusing Camellia.
- NPC schedules or pathing through town.
- Repeatable/procedural request board.
- Request-board menu/list UI.
- Mailbox or anonymous turn-ins.
- Reputation, relationship points, deadlines, quality ratings, or request penalties.
- New items, ingredients, recipes, regions, seasons, weather, farming, fishing, combat, or
  festivals.

## Risks

- The lane can easily become a village prototype. Keep it to one screen and one delivery.
- The board can easily become a request-management system. Keep it to one authored quest.
- Camellia already has a shop-visitor script. Avoid turning that script into a broad NPC
  framework; a small lane-specific script is safer for this slice.
- Save/load from a third world scene must preserve the existing 0.8 exterior behavior.
- The HUD tracker may say "Craft Glowberry Cordial" rather than "Craft 2 Glowberry
  Cordial"; accept this unless the wording is actively confusing.

## Success Criteria

- Mapleton exists as one tiny playable lane.
- A posted request starts from the notice board.
- The request ends with Marigold handing items to Camellia in person.
- The quest, inventory reward, scene transitions, Saffron follow, and save/load all work.
- Existing 0.6-0.9 focused verifiers still pass.

## Implementation Notes

- Added `scenes/world/MapletonLane.tscn`, a compact 720x480 placeholder lane with
  boundaries, path shapes, a notice board, a simple restaurant stall, Camellia, Marigold,
  Saffron, and a return door to `ShopExterior`.
- Added `ShopExterior/LaneDoor`, which sends Marigold to Mapleton Lane at
  `Vector2(360, 84)` facing south. The lane return door sends her back to the exterior at
  `Vector2(360, 420)` facing north.
- Added `camellia_cordial_delivery` to `data/quests.json`; it requires
  `camellia_first_request`, starts on Day 3, consumes `glowberry_cordial` x2, and rewards
  60 gold.
- Added `scripts/core/NoticeBoard.gd` for the one authored board request and
  `scripts/npc/CamelliaLaneNPC.gd` for the in-person delivery interaction.
- Added `tools/verify_vertical_slice_1_0.gd`, which checks lane loading, transition
  wiring, Saffron placement, save-scene compatibility, board quest start, delivery
  completion, gold/item changes, and quest save-data persistence.
- The user played the slice and reported "That works great" on 2026-06-27.
