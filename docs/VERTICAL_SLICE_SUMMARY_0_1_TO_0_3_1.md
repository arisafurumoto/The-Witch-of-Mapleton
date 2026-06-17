# Vertical Slice Summary - 0.1 to 0.3.1

> Current milestone summary as of 2026-06-17.

## Current Playable Shape

The game now has a small but complete cosy witch-shop loop:

1. Start in Marigold's shop.
2. Move around with collision, camera follow, and interaction prompts.
3. Saffron starts near Marigold and follows her.
4. Travel between the shop and the forest clearing.
5. Gather ingredients from daily-reset nodes.
6. Brew known recipes at the cauldron.
7. Serve the first customer or complete Sage's request.
8. Sleep, save, and start a new day.

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

The HUD currently shows day, gold, save/load toasts, quest start/complete toasts, and a
small active quest objective. The next slice should improve this guidance rather than
add a large journal.

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
- Completed slice plan files have been retired. The living truth is `docs/PROGRESS.md`
  plus this summary; `docs/plans/` should stay focused on active future plans.
