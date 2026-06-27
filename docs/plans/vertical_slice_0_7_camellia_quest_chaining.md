# Vertical Slice 0.7 - Camellia's First Request and Quest Chaining v1

> Status: IMPLEMENTED, HEADLESS-VERIFIED, AND MANUALLY ACCEPTED on 2026-06-27.

## Goal

Prove that the quest and recipe progression built through 0.6 can support a second
authored request without adding a broad village, schedule, relationship, or restaurant
system. Camellia should visit Marigold's shop only after Sage's first request is
complete, ask for one new drink, and permanently unlock that drink's recipe when the
request is turned in.

## Implementation Notes

- Added optional quest gates with `required_quests` and `minimum_day`, validated after
  all quest records load.
- Added `glowberry_cordial` item/recipe data and a first-pass 16x16 placeholder icon.
- Added `camellia_first_request`, gated behind completed `sage_first_request` and Day 2.
- Added `scenes/npc/Camellia.tscn` and `scripts/npc/CamelliaNPC.gd`; Camellia reuses the
  shop front-door route and centred counter visitor position.
- Registered Camellia with `closed_shop_visitors` only while present, and prevented her
  entrance from beginning during an active customer session.
- Added `tools/verify_vertical_slice_0_7.gd`.

## Player Flow

1. Complete `sage_first_request`.
2. Reach Day 2 or later.
3. Camellia enters the closed shop through the front visitor door.
4. Talk to Camellia and accept her request.
5. See Glowberry Cordial temporarily appear at the cauldron.
6. Gather the existing Moonleaf, Glowberry, and Forest Water ingredients.
7. Brew one Glowberry Cordial.
8. Return it to Camellia.
9. Receive gold and permanently learn the Glowberry Cordial recipe.
10. Sleep, Continue, and confirm the completed quest and learned recipe persist.

## Required Scope

### Quest prerequisites

- Add optional `required_quests: [String]` and `minimum_day: int` fields to quest data.
- Validate prerequisite quest IDs after all quest records have loaded, so JSON order
  does not affect validation.
- Add a small availability helper to `QuestSystem` or `QuestDatabase`; do not build a
  generic condition-expression system.
- `camellia_first_request` requires `sage_first_request` to be completed and cannot be
  offered before Day 2.
- Existing saves with no Camellia state treat the quest as `not_started`.

### Camellia's request

- Add `camellia_first_request` to `data/quests.json`.
- Working title: **A Brighter Menu**.
- Camellia asks Marigold to make one Glowberry Cordial as a possible restaurant drink.
- Keep start, reminder, completion, and reward text inline in the quest record, matching
  the current small authored-quest pattern.
- Reward 30 gold for the first balance pass and permanently unlock
  `glowberry_cordial`.
- Do not add relationship points, romance flags, restaurant reputation, or cafe systems.

### New item and recipe

- Add the stable item ID `glowberry_cordial` to `data/items.json`.
- Add the stable recipe ID `glowberry_cordial` to `data/recipes.json`.
- Use only existing ingredients:
  - Moonleaf x1
  - Glowberry x2
  - Forest Water x1
- Set `known_by_default: false` and gate temporary visibility with
  `quest_id: "camellia_first_request"`.
- Use a first-pass sell price of 24 gold. Do not add price balancing UI.
- While the request is active/ready, cap the quest brew to one batch using the existing
  cauldron behavior. After completion, normal ingredient-based batch limits apply.
- Add one native 16x16 inventory icon. A clear placeholder icon is sufficient for the
  implementation pass; production art can be a focused follow-up.

### Camellia shop visit

- Add a focused Camellia NPC scene/script with placeholder art if production walking
  art is not ready.
- Reuse the shop's front entrance and interior waypoint.
- Camellia enters only when her quest is available or unfinished, waits on the public
  side at the existing centred counter position, faces Marigold during dialogue, and
  leaves after completion.
- Do not refactor Sage and Camellia into a broad NPC framework in this slice. Extract a
  shared quest-visitor helper only if the implementation reveals small, concrete
  duplication that is safer to share than repeat.

### Closed-shop visitor coordination

- Reuse the existing `closed_shop_visitors` rule; quest visitors and browsing customers
  must not run simultaneously.
- Camellia joins the group only while present, matching Sage.
- The existing shop-sign prompt/toast remains the source of feedback.
- Camellia should not begin an entrance while a customer session is active.
- Keep the current one-customer deterministic shop session unchanged otherwise.

### Save, HUD, and migration

- Reuse the existing quest-state and `known_recipes` save fields; do not bump the save
  version unless the implementation changes the save shape.
- The current HUD tracker should show Camellia's ingredient progress and turn-in text
  through the existing recipe-output lookup.
- The existing recipe-learned toast should show `Recipe learned: Glowberry Cordial`.
- Loading a 0.6 save must not replay Camellia's rewards or mark the quest started.

## Implementation Order

1. [x] Add and validate quest prerequisite/minimum-day fields.
2. [x] Add Glowberry Cordial item, icon, and recipe data.
3. [x] Add Camellia's quest data and verify cauldron/HUD behavior without an NPC.
4. [x] Add Camellia's focused visitor scene and front-door route.
5. [x] Register Camellia with the existing closed-shop visitor coordination.
6. [x] Verify save/continue and 0.6 save compatibility.
7. [x] Add a focused 0.7 headless verification script and update the handoff.

## Acceptance Test

1. Start a new game and confirm Camellia does not appear before Sage's request is
   complete.
2. Complete Sage's request on Day 1 and confirm Camellia is still unavailable until
   Day 2.
3. On Day 2, confirm Camellia enters through the front door while the shop is closed.
4. Try to open the shop while Camellia is present and confirm it remains closed with a
   clear HUD message.
5. Talk to Camellia and confirm she turns toward Marigold and starts **A Brighter
   Menu**.
6. Confirm Glowberry Cordial appears at the cauldron only while required or permanently
   learned.
7. Confirm the quest tracker shows Moonleaf, Glowberry, and Forest Water progress.
8. Brew the cordial and confirm the tracker changes to the Camellia turn-in objective.
9. Turn it in; confirm the item is consumed, gold is awarded once, the quest completes,
   the recipe-learned toast appears, and Camellia leaves through the front door.
10. Confirm Glowberry Cordial remains listed with normal batch limits after completion.
11. Open the shop and confirm the existing generic customer sale still works.
12. Sleep, quit, and Continue; confirm Camellia remains completed and the recipe remains
    known without duplicate rewards or dialogue.
13. Load a 0.6 save and confirm all existing inventory, quest, recipe, shop stock, room,
    and day state still restore correctly.

## Non-Goals

- Shop exterior, village map, restaurant interior, or restaurant management.
- Relationships, romance, gifts, heart events, or Camellia's full character arc.
- NPC schedules, calendar seasons, time blocks, or pathfinding/navigation AI.
- New gathering areas, new raw ingredients, farming, or seed planting.
- Multiple simultaneous quests, a quest journal, or generic condition expressions.
- Multiple browsing customers, pricing, preferences, reputation, or shop upgrades.
- Full `npcs.json` / dialogue database migration. Revisit those when ambient dialogue,
  schedules, or a third reusable quest visitor creates a concrete need.

## Success Criteria

- A second authored quest can be gated by a completed quest and minimum day.
- The existing recipe-knowledge pipeline works for a second permanent unlock.
- Quest visitors and shop customers no longer overlap.
- The entire 0.1-0.6 loop remains playable without new mandatory systems.
