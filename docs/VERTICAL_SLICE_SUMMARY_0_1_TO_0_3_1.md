# Vertical Slice Summary - 0.1 to 0.5

> Current milestone summary as of 2026-06-18.

## Current Playable Shape

The game now has a small but complete cosy witch-shop loop:

1. Start in Marigold's shop.
2. Move around with collision, camera follow, and interaction prompts.
3. Saffron starts near Marigold and follows her.
4. Travel between the shop and the forest clearing.
5. Gather ingredients from daily-reset nodes.
6. Brew known recipes at the cauldron.
7. Stock a display and run the first customer browsing/checkout sequence, or complete
   Sage's request.
8. Sleep through a full-screen new-day transition, save, and start a new day with shop
   stock preserved.

## Vertical Slice 0.1 - First Potion Sale

0.1 proved the original end-to-end loop:

- Shop interior and forest clearing.
- Player movement, camera, collision, and interaction.
- Door transition between shop and forest.
- Item, recipe, inventory, gathering, crafting, shop sale, dialogue, cat companion,
  save/load, and day advancement systems.
- Calming Tea recipe:
  - Moonleaf x2
  - Forest Water x1
- Generic customer buys Calming Tea for gold.
- Bed advances the day and saves.

The result is a playable first sale from gather to brew to sell to sleep.

## Vertical Slice 0.2 - Sage's First Village Request

0.2 added the first quest-driven crafting request:

- Minimal `QuestDatabase` and `QuestSystem`.
- Saved quest state with `not_started`, `active`, `ready_to_turn_in`, and `completed`.
- Sage appears in the shop on day 1.
- Sage asks for Root-Wake Tonic and rewards 25 gold plus a Moonleaf Seed Packet.
- Sage now uses walking frames to enter the shop and leave after completion.
- Root-Wake Tonic is a quest-gated cauldron recipe.

Current Root-Wake Tonic recipe:

- Dewcap Mushroom x1
- Glowberry x2

This recipe was changed after 0.2 so it no longer overlaps Calming Tea.

## Vertical Slice 0.3 - Cauldron Crafting UI

0.3 replaced one-button cauldron crafting with an intentional cauldron UI path.

The first pass proved:

- `CauldronCraftingPanel` as an autoload UI scene.
- Cauldron interaction opens UI instead of immediately crafting.
- Player movement pauses while the cauldron panel is open.
- Recipes can be matched through recipe data instead of hard-coded behavior.

The raw ingredient-selection version was superseded by 0.3.1 because known recipes are
clearer for the current slice.

## Vertical Slice 0.3.1 - Known Recipe Cauldron UI

0.3.1 made the cauldron usable for the current authored loop:

- The cauldron lists known recipes from `data/recipes.json`.
- Quest-gated recipes appear only while their quest is active/ready.
- Unavailable known recipes can be selected for preview.
- Brew is disabled until the selected recipe's ingredients are held.
- Recipe details show output and ingredient counts.
- Quantity can be adjusted with `-` and `+`, capped by inventory.
- Quest recipes such as Root-Wake Tonic are capped to one brew.
- Batch brewing uses `CraftingSystem.craft_quantity()` so validation happens before
  ingredients are consumed.

Content added around 0.3.1:

- Dewcap Mushroom ingredient.
- Glowberry ingredient.
- Dewcap and Glowberry forest gatherables.
- New PNG forest assets, harvested bush variants, and spring tree replacement.
- Harvested-state art support for gatherables.

## Vertical Slice 0.4 - Quest and Recipe Guidance

0.4 made the existing quest and gathering loop readable without adding a journal:

- The HUD tracks Root-Wake Tonic ingredient counts while Sage's quest is active.
- The objective changes to the turn-in instruction once the tonic is crafted.
- Gatherables show item-name and quantity toasts.
- Dewcap Mushroom and Glowberry have native 16x16 inventory/recipe icons.

## Vertical Slice 0.5 - Shop Browsing Prototype

0.5 replaced the temporary direct customer sale with a deterministic Moonlighter-shaped
prototype:

- Marigold stocks one Calming Tea on one display and opens the shop at the sign.
- The animated customer enters through the door, browses, reserves the displayed item,
  routes around the counter, and waits on its public side.
- The chosen item's icon disappears immediately; checkout consumes the reserved stock
  and awards 18 gold.
- Customer and Sage use authored wall-safe door routes and walking animations at
  Marigold's movement/animation pace.
- Display stock persists through day advancement and save/continue.
- Sleeping fades to black, announces the new day, saves, and returns control.

The next planned milestone is 0.6, documented in
`docs/plans/vertical_slice_0_6_home_layout_and_recipe_progression.md`. It first creates
the three-door shop and separate room with scene-independent shop stock, then adds
persistent quest-rewarded recipe knowledge.

## Current Data Files

- `data/items.json`
  - Moonleaf
  - Forest Water
  - Dewcap Mushroom
  - Glowberry
  - Calming Tea
  - Root-Wake Tonic
  - Moonleaf Seed Packet
- `data/recipes.json`
  - Calming Tea
  - Root-Wake Tonic
- `data/quests.json`
  - Sage's first request
- `data/shop_requests.json`
  - First Calming Tea customer request

## Current Core UI

- `DialogueBox`
- `HUD`
- `InventoryPanel`
- `CauldronCraftingPanel`
- `TitleMenu`

The HUD currently shows day, gold, save/load and quest/gather toasts, a small active
quest objective, and the full-screen sleep/new-day transition.

## Important Constraints Going Forward

- Keep building one small system at a time.
- Do not add the full village, farming, romance, schedules, seasons, or extra NPC chains
  yet.
- Prefer JSON data for items, recipes, quests, and requests.
- Keep UI compact for 640x360.
- GDScript warnings are treated as errors; use explicit types where inference would
  become `Variant`.
- Preserve pixel art source quality. Do not resample source art in place.

## Known Quirks

- The normal headless startup command currently exits with code 1 while printing no
  project error lines, but targeted smoke tests have been passing.
- The living truth is `docs/PROGRESS.md`, this summary, and the active 0.6 plan in
  `docs/plans/`.
