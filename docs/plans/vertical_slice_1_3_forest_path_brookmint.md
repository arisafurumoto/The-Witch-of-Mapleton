# Vertical Slice 1.3 - Forest Path Unlock and Brookmint Tea v1

> Status: PLANNED.
> Start after Vertical Slice 1.2 is manually accepted or otherwise safely backed up.

## Goal

Prove the first quest-gated world expansion: completing Sage's Day 4 restock request
opens a tiny new forest path with one new gatherable, and a follow-up Camellia request
uses that ingredient in one new recipe.

This should feel like Mapleton is beginning to widen, but it must stay small. Add one
screen, one ingredient, one recipe, and one authored request. Do not start a broad map,
region, biome, season, farming, or request-board system.

## Why This Comes Next

Vertical Slice 1.2 proved a short authored board sequence and gave Sage a tiny lane
presence. The next useful progression proof is not another same-shaped delivery; it is
showing that quest completion can unlock a new place to gather and a new crafted item.

This is the smallest step toward the long-term "authored regions unlock through quest
chains" direction without jumping to a full village map or larger forest.

## Player Flow

1. Complete `sage_seedling_restock`.
2. Sleep to Day 5.
3. Read the Mapleton Lane notice board.
4. Accept Camellia's new Brookmint Tea request.
5. Go to the existing forest clearing.
6. Use the newly-opened forest path transition.
7. Enter a tiny `ForestPath` scene.
8. Gather Brookmint.
9. Return to the shop.
10. Brew Brookmint Tea at the cauldron.
11. Open the notebook and confirm the request and recipe counts are readable.
12. Deliver Brookmint Tea to Camellia in Mapleton Lane.
13. Receive gold and permanently learn Brookmint Tea.
14. Sleep/save/continue and confirm the quest, learned recipe, and scene position persist.

## Required Scope

### New Area

- Add one small scene: `scenes/world/ForestPath.tscn`.
- Keep it the same rough scale as existing compact scenes.
- Include:
  - `Player`;
  - `Cat`;
  - camera limits;
  - boundary collisions;
  - return transition to `ForestClearing`;
  - one or two Brookmint gatherables;
  - placeholder background/ground shapes or reused spring forest background assets.
- Do not add caves, multiple exits, a map UI, minimap, pathfinding, enemies, weather, or
  new forest mechanics.

### Locked Forest Transition

- Add a transition from `ForestClearing.tscn` to `ForestPath.tscn`.
- The transition should be unavailable until `sage_seedling_restock` is completed.
- Prefer the smallest readable implementation:
  - a `QuestLockedDoor.gd` subclass of `Door.gd`, or
  - a small optional quest requirement on `Door.gd` if that stays clean.
- Locked interaction should show a short dialogue or HUD toast, such as:
  `The path is still tangled with sleepy roots.`
- Once unlocked, use explicit player arrival position/facing like existing doors.
- Saffron should follow through the transition using the existing transition placement
  pattern.

### New Item

Add one ingredient to `data/items.json`.

Suggested id:

```text
brookmint
```

Suggested display name:

```text
Brookmint
```

Use a small placeholder icon if quick, or an existing fallback color if the UI already
handles missing icons safely. Do not polish item art beyond slice needs.

### New Recipe

Add one cauldron recipe to `data/recipes.json`.

Suggested id:

```text
brookmint_tea
```

Suggested content:

- Name: `Brookmint Tea`
- Station: `cauldron`
- Ingredients:
  - `brookmint` x2
  - `forest_water` x1
- Output:
  - `brookmint_tea` x1
- `known_by_default`: false
- `quest_id`: `camellia_brookmint_request`

This recipe should appear temporarily while the request is active/ready and become
permanently known when the quest completes, matching the existing quest-recipe pattern.

### New Quest

Add one quest to `data/quests.json`.

Suggested id:

```text
camellia_brookmint_request
```

Suggested content:

- Title: `A Fresh Pot`
- NPC: `Camellia`
- Turn-in: `brookmint_tea` x1
- Reward: 80 gold
- Reward recipe: `brookmint_tea`
- Required quest: `sage_seedling_restock`
- Minimum day: 5

Start it from the existing notice board sequence. Complete it by talking to Camellia in
Mapleton Lane.

### Notice Board and Camellia Lane Interaction

- Add `camellia_brookmint_request` to the board's authored quest list after
  `sage_seedling_restock`.
- Extend Camellia's lane interaction to support a tiny ordered quest list, mirroring the
  notice-board approach if needed.
- Keep the existing `quest_id` export compatibility if it helps older verifier/scenes.
- Do not build a request menu, repeatable jobs, deadlines, categories, or relationship
  rewards.
- Do not add a generic NPC database unless the implementation becomes clearly simpler
  than the small local script change.

### Notebook, HUD, and Shop

- Rely on the existing notebook and HUD behavior.
- Confirm the notebook shows:
  - `A Fresh Pot`;
  - `Brookmint Tea 0/1` and `1/1`;
  - Brookmint Tea in the Recipes tab while quest-active/ready;
  - Brookmint and Forest Water owned/needed counts.
- Brookmint Tea may be stockable/sellable after it is learned if the existing stockable
  recipe behavior naturally allows it. Do not add new shop UI or customer preference
  logic for it.

### Save/Load

- No new save fields should be needed.
- The new quest state, learned recipe, inventory, current scene, and player position
  should persist through existing save data.
- Gatherable depletion should use `DaySystem` with stable gatherable ids.

## Suggested Files

```text
docs/plans/vertical_slice_1_3_forest_path_brookmint.md
data/items.json
data/recipes.json
data/quests.json
scripts/core/QuestLockedDoor.gd
scripts/npc/CamelliaLaneNPC.gd
scenes/world/ForestClearing.tscn
scenes/world/ForestPath.tscn
tools/verify_vertical_slice_1_3.gd
docs/PROGRESS.md
```

Optional only if quick and useful:

```text
art/items/brookmint.png
art/items/brookmint_tea.png
```

## Implementation Order

1. Run focused 0.6-1.2 verifiers before editing.
2. Inspect `ForestClearing.tscn`, `Door.gd`, `Gatherable.gd`, `MapletonLane.tscn`,
   `NoticeBoard.gd`, `CamelliaLaneNPC.gd`, `RecipeKnowledgeSystem.gd`, and the 1.2
   verifier.
3. Add `brookmint` and `brookmint_tea` data.
4. Add `camellia_brookmint_request` quest data.
5. Add the locked forest transition.
6. Add `ForestPath.tscn` with Brookmint gatherable(s), return door, Player, Cat, bounds,
   and camera limits.
7. Add the new quest id to the notice board sequence.
8. Extend Camellia's lane interaction to complete the Brookmint Tea request.
9. Add `tools/verify_vertical_slice_1_3.gd`.
10. Run 0.6-1.3 focused verifiers.
11. Update `docs/PROGRESS.md` and this plan with implementation notes.

## Verification

Add `tools/verify_vertical_slice_1_3.gd`.

The verifier should check:

- `ItemDatabase` loads `brookmint` and `brookmint_tea`.
- `RecipeDatabase` loads `brookmint_tea`.
- Brookmint Tea requires Brookmint x2 and Forest Water x1.
- `QuestDatabase` loads `camellia_brookmint_request`.
- The quest requires `sage_seedling_restock` and minimum Day 5.
- The forest path transition is locked before `sage_seedling_restock` is completed.
- The forest path transition unlocks after `sage_seedling_restock` is completed.
- `ForestPath.tscn` exists and includes Player, Cat, bounds, return door, camera limits,
  and Brookmint gatherable(s).
- Saffron arrives behind Marigold when entering and returning.
- The notice board starts `camellia_brookmint_request` only after gates are satisfied.
- Brookmint Tea appears in the cauldron/notebook while the quest is active or ready.
- Gathering Brookmint updates Inventory and depletes the gatherable for the day.
- Crafting Brookmint Tea consumes Brookmint and Forest Water.
- Camellia completes the request, consumes exactly one Brookmint Tea, awards 80 gold,
  and unlocks the recipe permanently.
- Quest state and learned recipe survive save-data round trips.
- Existing 0.6-1.2 verifiers still pass.

## Manual Acceptance Test

1. Complete `sage_seedling_restock`.
2. Sleep to Day 5.
3. Go to the forest clearing and confirm the new path is available.
4. Read the notice board and accept **A Fresh Pot**.
5. Open the notebook and confirm Brookmint Tea appears with missing ingredients.
6. Enter the forest path and gather Brookmint.
7. Return to the shop and brew Brookmint Tea.
8. Deliver it to Camellia in Mapleton Lane.
9. Confirm the tea is removed, gold increases by 80, and Brookmint Tea is learned.
10. Sleep/save/continue and confirm the quest and recipe remain completed/known.
11. Confirm existing Sage/Camellia delivery and shop-sale loops still work.

## Non-Goals

- Full forest region.
- Multiple new screens.
- Caves, combat, enemies, tools, stamina, or HP.
- Seasons, weather, or seasonal gather tables.
- Farming or using Moonleaf Seed Packet.
- New NPCs.
- NPC schedules.
- Plant shop or restaurant interiors.
- Request-board menu/list UI.
- Repeatable/procedural requests.
- Map markers, minimap, or world map.
- Item quality, traits, star ratings, or advanced recipe results.
- Shop pricing, customer preferences, or new customer types.

## Risks

- Adding a new area can easily become a map system. Keep it one small scene with one
  return path.
- Adding a new gatherable can tempt seasonal/resource tables. Use the existing simple
  `Gatherable` pattern.
- Adding another Camellia request can tempt a generic quest/NPC framework. Extend only
  what the slice needs.
- The locked path should be obvious without becoming a tutorial system. A short locked
  line is enough.

## Success Criteria

- A completed quest unlocks a new tiny gathering space.
- The player can gather one new ingredient and craft one new recipe.
- The new recipe participates in the existing notebook, cauldron, quest, and save/load
  systems.
- Existing shop, board, lane, forest, Saffron, and save/load loops remain intact.
