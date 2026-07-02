# The Witch of Mapleton - Progress & Handoff

> Read this first when starting a session.
> Last updated: 2026-07-03.
> This file is the compact handoff. Detailed history lives in the milestone summaries
> and per-slice plans under `docs/plans/`.

## Current Snapshot

- Engine: **Godot 4.1.3** at `/Applications/Godot.app`.
- Main scene: `scenes/ui/TitleMenu.tscn`.
- Current playable chain: First Potion Sale through **Vertical Slice 1.8.1 - Display
  UX and Testing Balance Polish**.
- User has manually confirmed **1.3** and **1.4** are working.
- **1.5** through **1.8.1** are implemented and headless-verified; 1.5 and 1.6 still
  need manual visual acceptance, and 1.7/1.8/1.8.1 need manual play acceptance.
- Next planned slice: **1.9 - Simple Customer Variety and Display Choice v1**.
  Plan stub: `docs/plans/vertical_slice_roadmap.md`.

Near-term direction:

```text
1.8.1 display UX/testing balance polish
-> 1.9 simple customer variety/display choice
-> 1.10 Mapleton Lane ambient dialogue
```

Scope guard: keep building one tiny, working loop at a time. Do not pull in full town
systems, schedules, relationships, seasons, full farming, combat, item quality, shop
pricing, cafe systems, or Homunculi until a focused slice needs them.

## What Is Playable

The game currently supports:

- Start menu with Continue/New Game.
- Shop, bedroom, forest clearing, shop exterior, Mapleton Lane, and Forest Path scenes.
- Player movement, camera, collision, interactions, scene transitions, save/load, day
  advancement, inventory, gathering, crafting, shop sale, dialogue, HUD, notebook, and
  Saffron follow.
- Two displays that each hold a stack of one chosen sellable crafted item, with a small
  picker UI and a way to take stock back before a customer reserves it. Quest-active
  crafted goods such as Root-Wake Tonic can be stocked if Marigold is carrying them.
- Deterministic customer queue from total displayed stock.
- One tiny Moonleaf planter on the shop exterior property that consumes a Moonleaf Seed
  Packet, grows through sleep/day advancement, saves its state, and uses existing
  Moonleaf bush art when mature.
- Forest Water can be gathered from the original clearing spring and from the Forest Path
  brook.
- Quest-driven first-week chain:
  - Day 1 Sage request: Root-Wake Tonic.
  - Day 2 Camellia request: Glowberry Cordial.
  - Day 3 board delivery: Glowberry Cordial x2 to Camellia in Mapleton Lane.
  - Day 4 board delivery: Root-Wake Tonic to Sage in Mapleton Lane.
  - Day 5 board request: Brookmint Tea after Forest Path unlock.
- Notebook (`J`) with Quests and Recipes tabs.
- Dialogue portraits for Marigold, Sage, and Camellia, including per-line
  speaker/expression switching. Marigold appears on the lower-right; NPCs appear on the
  lower-left; speakers without portrait art hide the portrait slot.
- Readability blockouts plus first-pass prop art for the shop exterior, Mapleton Lane,
  forest clearing, and forest path, including the updated shop facade art, clearer path
  mouths/edges, and a visual-only future planter marker on the shop property.

## Slice Index

| Slice | Status | Summary |
| --- | --- | --- |
| 0.1 First Potion Sale | Complete | Original 14-system playable loop. |
| 0.2 Sage's First Village Request | Complete | Quest state, Root-Wake Tonic, Sage reward. |
| 0.3 / 0.3.1 Cauldron UI | Complete | Ingredient panel, then known-recipe cauldron UI. |
| 0.4 Quest and Recipe Guidance | Complete | Tracker ingredient progress and gather toasts. |
| 0.5 Shop Browsing Prototype | Complete | One stocked display, one customer checkout. |
| 0.6 Home Layout and Recipe Progression | Complete | Separate room, front/forest/room doors, recipe unlock persistence. |
| 0.7 Camellia's First Request | Complete, user accepted | Day 2 Camellia quest and Glowberry Cordial unlock. |
| 0.8 Shop Threshold and Arrival | Complete | Tiny shop exterior threshold and Saffron transition placement. |
| 0.9 Stackable Display and Customer Queue | Complete | Stacked display stock and sequential customer queue. |
| 1.0 Mapleton Lane and First Hand Delivery | Complete, user accepted | Tiny lane, notice board, Camellia hand delivery. |
| 1.1 Notebook / Quest and Recipe Notes | Complete | Read-only quest/recipe notebook. |
| 1.2 Sage's Posted Delivery | Complete | Day 4 board request and Sage plant-stall presence. |
| 1.3 Forest Path and Brookmint Tea | Complete, user accepted | Quest-gated Forest Path, Brookmint, Brookmint Tea. |
| 1.4 Dialogue Portraits | Complete, user accepted | Large portraits/nameplates and alternating speaker lines. |
| 1.5 Map Blockout and Layout Readability | Implemented, headless-verified; needs manual acceptance | Clearer current map blockouts before polished tiles/props. |
| 1.6 Focused Tileset and Prop Production Pass | Implemented, headless-verified; needs manual acceptance | Small reusable prop sprites layered onto the current maps without mechanics changes. |
| 1.7 Moonleaf Planter | Implemented, headless-verified; needs manual acceptance | One saved Moonleaf planter payoff for Sage's seed packet reward. |
| 1.8 Second Display and Mixed Shop Stock | Implemented, headless-verified; needs manual acceptance | Second saved shop display and deterministic customer purchases from either display. |
| 1.8.1 Display UX and Testing Balance Polish | Implemented, headless-verified; needs manual acceptance | Display item picker, take-back action, mature Moonleaf art reuse, and a Forest Path water source. |

Detailed plans:

```text
docs/plans/vertical_slice_0_4_quest_recipe_guidance.md
docs/plans/vertical_slice_0_5_shop_browsing_prototype.md
docs/plans/vertical_slice_0_6_home_layout_and_recipe_progression.md
docs/plans/vertical_slice_0_7_camellia_quest_chaining.md
docs/plans/vertical_slice_0_8_shop_threshold_and_arrival.md
docs/plans/vertical_slice_0_9_stackable_display_customer_queue.md
docs/plans/vertical_slice_1_0_mapleton_lane_hand_delivery.md
docs/plans/vertical_slice_1_1_notebook_notes.md
docs/plans/vertical_slice_1_2_sage_posted_delivery.md
docs/plans/vertical_slice_1_3_forest_path_brookmint.md
docs/plans/vertical_slice_1_4_dialogue_portraits.md
docs/plans/vertical_slice_1_5_map_blockout_readability.md
docs/plans/vertical_slice_1_6_focused_tileset_prop_pass.md
docs/plans/vertical_slice_1_7_moonleaf_planter.md
docs/plans/vertical_slice_1_8_second_display_mixed_stock.md
docs/plans/vertical_slice_roadmap.md
```

Older milestone summaries:

```text
docs/VERTICAL_SLICE_SUMMARY_0_1_TO_0_3_1.md
docs/VERTICAL_SLICE_SUMMARY_0_4_TO_0_6.md
```

## Run And Verify

Headless import after adding or renaming art:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --quit
```

Headless load/parse check:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit
```

Focused verifier pattern:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_4.gd
```

Before starting the next implementation slice, run the focused verifiers for affected
systems. For 1.5, start with:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_0_8.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_0.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_3.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_4.gd
```

Play in Godot:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

## Current Architecture

Autoloads, in project order:

```text
ItemDatabase
Inventory
RecipeDatabase
RecipeKnowledgeSystem
CraftingSystem
ShopRequestDatabase
ShopSystem
ShopState
AudioSystem
QuestDatabase
QuestSystem
DialogueBox
DaySystem
PlanterSystem
HUD
InventoryPanel
CauldronCraftingPanel
DisplayStockPanel
NotebookPanel
SaveSystem
```

Important ownership:

- `Inventory` stores items and gold across scene changes.
- `DaySystem` stores day and daily gatherable depletion.
- `QuestSystem` stores quest states and checks `required_quests` / `minimum_day`.
- `RecipeKnowledgeSystem` stores permanently unlocked recipes.
- `ShopState` stores persistent display stock independently of loaded scenes.
- `PlanterSystem` stores the one Moonleaf planter state independently of loaded scenes.
- `SaveSystem` stores inventory, gold, day/gatherable state, quest state, known recipes,
  persistent display stock, planter state, current scene, and player position.
- `DialogueBox` supports both old string-array lines and optional per-line dictionaries:
  `{ "speaker": "...", "expression": "...", "text": "..." }`.

Core data:

```text
data/items.json
data/recipes.json
data/shop_requests.json
data/quests.json
```

Core scenes:

```text
scenes/world/ShopInterior.tscn
scenes/world/MarigoldRoom.tscn
scenes/world/ForestClearing.tscn
scenes/world/ForestPath.tscn
scenes/world/ShopExterior.tscn
scenes/world/MapletonLane.tscn
scenes/world/Door.tscn
scenes/world/Gatherable.tscn
scenes/player/Player.tscn
scenes/npc/Cat.tscn
scenes/npc/Camellia.tscn
scenes/ui/DialogueBox.tscn
scenes/ui/HUD.tscn
scenes/ui/InventoryPanel.tscn
scenes/ui/CauldronCraftingPanel.tscn
scenes/ui/DisplayStockPanel.tscn
scenes/ui/NotebookPanel.tscn
```

Notable scripts added after the base slice:

```text
scripts/core/NoticeBoard.gd
scripts/core/QuestLockedDoor.gd
scripts/core/MoonleafPlanter.gd
scripts/npc/CamelliaLaneNPC.gd
scripts/npc/SageLaneNPC.gd
scripts/systems/PlanterSystem.gd
```

## Art Pipeline Rules

These are hard rules:

- Never overwrite, crop, resize, resample, recolour, clean, or repaint user-supplied
  humanoid character art.
- Snapshot to `backups/` before destructive art operations.
- Package humanoid runtime PNG frames with `tools/build_character_spriteframes.py`.
- If a character faces the wrong way in-game, fix the packager direction mapping and
  trust the in-game observation.
- Keep sprite feet/base at the bottom-centre of the canvas; offset `AnimatedSprite2D`
  so feet sit at the node origin.
- Keep nearest-neighbor pixel filtering.

Current character resources:

```text
Marigold: art/characters/marigold/Marigold.tres
Saffron: scenes/npc/Cat.tscn
Generic customer: art/characters/npcs/generic_customer/GenericCustomer.tres
Sage: art/characters/npcs/sage/Sage.tres
Camellia: art/characters/npcs/camellia/Camellia.tres
```

Portraits currently mapped in `DialogueBox`:

```text
art/characters/marigold/portraits/
art/characters/npcs/sage/portraits/
art/characters/npcs/camellia/portraits/
```

## Recently Completed Slice: 1.5

Implement `docs/plans/vertical_slice_1_5_map_blockout_readability.md`.

Goal:

- Make existing playable spaces readable at 640x360 before polished map art.

Changed files:

```text
scenes/world/ShopExterior.tscn
scenes/world/MapletonLane.tscn
scenes/world/ForestClearing.tscn
scenes/world/ForestPath.tscn
tools/verify_vertical_slice_1_5.gd
docs/PROGRESS.md
```

Main acceptance:

- Clear paths and exits in ShopExterior, Mapleton Lane, Forest Clearing, and Forest Path.
- Future planter/garden marker exists in ShopExterior but is visual-only.
- Existing NPC, board, gathering, transition, Saffron, dialogue, cauldron, shop, and
  save/load behavior remains unchanged.

Implementation notes:

- ShopExterior now has clearer path edges, lane mouth staging, and a visual-only
  `FuturePlanterMarker`.
- Mapleton Lane now has stronger path/approach cues around the board, restaurant stall,
  plant stall, and return route.
- Forest Clearing now has subtle route cues for the shop return and deeper forest path.
- Forest Path now has stronger return, trail edge, brook bank, and thicket readability
  cues.
- `tools/verify_vertical_slice_1_5.gd` checks scene loading, transition wiring, camera
  limits, boundary collision nodes, key NPC/interactable/gatherable presence, and that
  `FuturePlanterMarker` remains visual-only.
- Headless checks passed for every focused verifier from 0.6 through 1.5 after
  implementation.

Non-goals:

- No new quests, items, recipes, NPCs, areas, farming, map UI, schedules, decoration, or
  final tileset/prop production.

## Recently Completed Slice: 1.6

Implement `docs/plans/vertical_slice_1_6_focused_tileset_prop_pass.md`.

Goal:

- Replace the most visible placeholder shapes with small, reusable, readable visual
  assets for the existing maps.

Changed files:

```text
art/props/shop_exterior/
art/props/town/
art/props/forest/brook_sparkles.png
art/props/forest/brook_sparkles.png.import
art/props/forest/brookmint_patch.png
art/props/forest/brookmint_patch.png.import
art/props/forest/forest_path_gate.png
art/props/forest/forest_path_gate.png.import
art/props/forest/thicket.png
art/props/forest/thicket.png.import
scenes/world/ShopExterior.tscn
scenes/world/MapletonLane.tscn
scenes/world/ForestClearing.tscn
scenes/world/ForestPath.tscn
tools/verify_vertical_slice_1_6.gd
docs/plans/vertical_slice_1_6_focused_tileset_prop_pass.md
docs/PROGRESS.md
```

Main acceptance:

- Shop exterior facade/path/garden-corner props.
- Mapleton Lane stall/board/fence/edge props.
- Forest Clearing and Forest Path ground/path/brook/thicket/gathering readability.
- Existing NPC, board, gathering, transition, Saffron, dialogue, cauldron, shop, and
  save/load behavior remains unchanged.
- `FuturePlanterMarker` remains visual-only and non-interactive.

Implementation notes:

- Added deterministic low-resolution PNG prop sprites rather than broad tileset tooling.
- ShopExterior now overlays a clearer witch-shop facade, front step, fences, lantern,
  mailbox, crates, shrub, and polished visual-only planter marker.
- Mapleton Lane now overlays clearer notice board, restaurant stall, plant stall, fence,
  and shrub-bank sprites.
- Forest Clearing now has a more readable forest path gate sprite while keeping the
  quest-locked door and root tangle.
- Forest Path now has sprite-backed Brookmint patches, thicket sprites, and brook
  sparkle cues.
- `tools/verify_vertical_slice_1_6.gd` checks scene loading, transition wiring, required
  gameplay nodes, visual-only planter status, and new art resource imports.
- Headless focused verifiers passed for 0.8, 1.0, 1.3, 1.4, 1.5, and 1.6 after
  implementation.

Non-goals:

- No new mechanics, quests, NPCs, areas, schedules, farming, decoration mode, or broad
  tileset tooling.

## Recently Completed Slice: 1.7

Implement `docs/plans/vertical_slice_1_7_moonleaf_planter.md`.

Goal:

- Pay off Sage's Moonleaf Seed Packet reward with one tiny fixed Moonleaf planter.

Changed files:

```text
art/props/shop_exterior/moonleaf_planter_harvested.png
art/props/shop_exterior/moonleaf_planter_harvested.png.import
art/props/shop_exterior/moonleaf_planter_ready.png
art/props/shop_exterior/moonleaf_planter_ready.png.import
art/props/shop_exterior/moonleaf_planter_sprout.png
art/props/shop_exterior/moonleaf_planter_sprout.png.import
art/props/shop_exterior/moonleaf_planter_young.png
art/props/shop_exterior/moonleaf_planter_young.png.import
project.godot
scenes/world/ShopExterior.tscn
scripts/core/MoonleafPlanter.gd
scripts/systems/PlanterSystem.gd
scripts/systems/SaveSystem.gd
tools/verify_vertical_slice_1_7.gd
docs/plans/vertical_slice_1_7_moonleaf_planter.md
docs/PROGRESS.md
```

Implementation notes:

- Added `PlanterSystem` for a single stable planter ID, not a generic farming system.
- The shop exterior `FuturePlanterMarker` remains visual-only for 1.6 preservation; the
  new `MoonleafPlanter` is a separate interactable sibling over the garden marker.
- Planting consumes `moonleaf_seed_packet` x1, growth is computed from `DaySystem`, and
  harvesting ready Moonleaf gives `moonleaf` x2.
- Save/load now includes `planters`.
- Headless verifier `tools/verify_vertical_slice_1_7.gd` passed.

Non-goals:

- No full farming, watering, tools, crop grids, seasons, crop quality, stamina, seed
  shop, or garden expansion.

## Recently Completed Slice: 1.8

Implement `docs/plans/vertical_slice_1_8_second_display_mixed_stock.md`.

Goal:

- Let Marigold stock two small displays at once and sell from either display through the
  existing deterministic customer queue.

Changed files:

```text
scenes/world/ShopInterior.tscn
scripts/core/ShopDisplay.gd
scripts/core/ShopOpenSign.gd
scripts/npc/CustomerNPC.gd
tools/verify_vertical_slice_1_8.gd
docs/plans/vertical_slice_1_8_second_display_mixed_stock.md
docs/PROGRESS.md
```

Implementation notes:

- Added `SecondShopDisplay` with stable display ID `side_display`.
- `ShopState` already supported multiple display IDs, so no new shop persistence system
  was needed.
- `ShopOpenSign` totals available stock across `shop_displays`.
- `CustomerNPC` picks the first stocked display by stable display ID, reserves that
  display, and consumes from the reserved display at checkout.
- The second display prefers `glowberry_cordial` when stocking from inventory, while
  still using existing known-recipe stockability rules.
- Headless verifier `tools/verify_vertical_slice_1_8.gd` passed.

Non-goals:

- No price setting, customer preferences, simultaneous customers, shop upgrades, direct
  inventory sales, decoration mode, or schedules.

## Recently Completed Slice: 1.8.1

Implement immediate feedback from 1.7/1.8 manual testing.

Goal:

- Fix display usability and reduce ingredient-test friction without pulling in the full
  time system yet.

Changed files:

```text
data/items.json
scenes/world/ForestPath.tscn
scenes/world/ShopExterior.tscn
scenes/ui/DisplayStockPanel.tscn
scripts/core/ShopDisplay.gd
scripts/player/PlayerController.gd
scripts/ui/DisplayStockPanel.gd
scripts/ui/TitleMenu.gd
tools/verify_vertical_slice_0_9.gd
tools/verify_vertical_slice_1_8_1.gd
docs/PROGRESS.md
```

Implementation notes:

- Added `DisplayStockPanel`, a compact display picker UI for choosing which known
  sellable crafted good to stock.
- Displays now support taking unreserved stock back into inventory.
- Root-Wake Tonic now has a shop sell price of 22 gold.
- Display stockability now allows recipes that are permanently known or temporarily
  available through an active/ready quest, matching the cauldron recipe list behavior.
- The updated shop facade sprite is scaled and anchored to the existing front step, and
  the old facade blockout polygons are hidden so they do not show through transparent
  parts of the new art.
- Mature Moonleaf planter visuals now use the existing `moonleaf_bush.png` art; sprout
  and young stages remain the small planter-specific sprites.
- Added `BrookWaterGathering` to Forest Path so Forest Water can be gathered from the
  brook after the path is unlocked.
- The time system is deferred to a dedicated slice because it should own shop hours,
  daily schedule rules, save data, UI, and any NPC timing behavior together.
- Headless verifiers `tools/verify_vertical_slice_0_9.gd`,
  `tools/verify_vertical_slice_1_6.gd`, `tools/verify_vertical_slice_1_8.gd`, and
  `tools/verify_vertical_slice_1_8_1.gd` passed after this feedback patch.

Non-goals:

- No clock/time-of-day system yet.
- No shop-hour rules, NPC schedules, customer preferences, or expanded farming.

## Current Next Slice: 1.9

Use the roadmap entry for **Vertical Slice 1.9 - Simple Customer Variety and Display
Choice v1** as the starting point, but write a focused plan before implementing it.

Likely focus:

- Add a tiny amount of customer variety and display-choice flavor while keeping customer
  visits sequential and deterministic.

Non-goals:

- No relationship points, schedules, reputation, price sensitivity, simultaneous
  browsing, or complex preferences.

## Future Feature Notes

- Add a small NPC presence/schedule system before adding more simultaneous town/shop
  appearances. It should answer "where should this NPC be right now?" from day, quest
  state, and simple authored rules, then hide scene-local NPC instances that do not
  belong. Do not save every NPC's raw position yet; save high-level story/schedule state
  and derive presence from that.

## Longer-Term Docs

Use these only when the current slice needs design context:

- `docs/GDD.md`: long-term vision and deferred systems.
- `docs/STYLE_GUIDE.md`: visual direction, art pipeline, technical art specs.
- `docs/DATA_SCHEMA.md`: JSON schemas and save/data rules.
- `docs/CHARACTERS.md`: cast concepts, including many characters not yet in scope.
- `docs/AI_WORKFLOW.md`: original AI development process; mostly historical now.
- `docs/plans/vertical_slice_roadmap.md`: rough 1.5+ direction, not a binding contract.

## Known Quirks

- GDScript warnings are treated as errors. Avoid `Variant` inference; use typed vars and
  helpers such as `minf` / `maxi` where needed.
- `.tscn` `load_steps` is a hint; keep it at least as high as the actual resource count
  when hand-editing scenes.
- After adding or renaming art files, run the headless editor import pass before
  testing.
- `backups/` is git-ignored and `.gdignore`d.
