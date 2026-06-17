# Vertical Slice 0.3 - Cauldron Crafting UI

> Status: DONE (2026-06-17), then superseded by Vertical Slice 0.3.1.
> 0.3 proved the cauldron UI path; 0.3.1 changed the player-facing UI to known recipes.

## Goal

Make cauldron crafting feel like an intentional player action instead of a one-button
recipe trigger.

The player should be able to interact with the cauldron, choose ingredients from their
inventory, brew them, and receive an item when the chosen ingredients exactly match a
known cauldron recipe.

This is the first step toward Atelier-style alchemy, but it should not become a full
quality, trait, discovery, or synthesis-grid system yet.

## Player Flow

1. Player gathers ingredients.
2. Player returns to the shop.
3. Player interacts with the cauldron.
4. A compact cauldron crafting UI opens.
5. Player selects ingredients from inventory.
6. Selected ingredients appear in a small cauldron/ingredient tray.
7. Player presses Brew.
8. If the selected ingredients exactly match a known cauldron recipe, the ingredients
   are consumed and the output item is added to inventory.
9. If there is no match, show a gentle failure message and do not consume ingredients.
10. The player can close the UI and continue playing.

## Required Scope

Build only the v1 ingredient-selection loop:

- A reusable UI scene, likely `scenes/ui/CauldronCraftingPanel.tscn`.
- A UI script, likely `scripts/ui/CauldronCraftingPanel.gd`.
- Cauldron interaction opens the UI instead of immediately crafting.
- Inventory ingredient list shows item names, icons, and quantities.
- Player can add/remove selected ingredients.
- Brew button checks the selected ingredient counts against cauldron recipes.
- Matching recipe crafts through `CraftingSystem` or a small new helper.
- No-match result does not consume ingredients in this first version.

## Data / System Additions

Keep using `data/recipes.json`.

Likely useful helpers:

```gdscript
RecipeDatabase.get_recipes_for_station(station: String) -> Array[Dictionary]
RecipeDatabase.find_matching_recipe(station: String, ingredients: Dictionary) -> Dictionary
```

Matching should be exact for v1:

- Same ingredient IDs.
- Same quantities.
- No extra ingredients.
- No substitutions.

## Content

Initial implementation can use the existing recipes:

- Calming Tea: Moonleaf x2 + Forest Water x1
- Root-Wake Tonic: Moonleaf x2 + Forest Water x1, quest-gated to Sage's quest

Because those recipes currently share the same ingredients, add new recipe/ingredient
content only after the UI works. Keep additions tiny:

- Add 2-3 new gatherable ingredients at most.
- Add 2-3 cauldron recipes at most.
- Prefer authored, readable recipes over systemic complexity.

Potential simple ingredients:

- Sunpetal
- Dewcap Mushroom
- Glowberry

Potential simple recipes:

- Brightening Brew
- Gentle Remedy
- Focus Draught

Treat these names as placeholders until the implementation pass chooses final IDs and
dialogue needs.

## Non-Goals

Do not add:

- Full recipe book UI.
- Recipe discovery rules.
- Quality, traits, ranks, stars, or grades.
- Ingredient categories or substitutions.
- Timed minigames.
- Failure items or ingredient loss.
- Cauldron animation polish beyond a small feedback message.
- New quest chains.
- Farming, planting, or seed usage.
- Multiple crafting stations.
- Shop economy changes.

## UX Notes

- Keep the panel compact for the 640x360 internal resolution.
- Use item icons where available.
- Keep controls clear with keyboard/controller-friendly focus if simple.
- Use plain labels like inventory, selected ingredients, and brew result.
- Do not add a tutorial page; the UI should be understandable from layout and labels.

## Manual Test Plan

1. Start a new game.
2. Gather Moonleaf and Forest Water.
3. Interact with the cauldron.
4. Confirm the cauldron UI opens and player movement pauses if needed.
5. Add Moonleaf x2 and Forest Water x1.
6. Press Brew.
7. Confirm a matching recipe crafts and inventory updates.
8. Try a non-matching ingredient set.
9. Confirm no ingredients are consumed.
10. Confirm Sage's Root-Wake Tonic can still be brewed while his quest is active.
11. Confirm Calming Tea can still be brewed for the 0.1 customer flow.
12. Save/load and confirm inventory remains correct.

## Notes

- `CraftingStation` now opens `CauldronCraftingPanel`; the old one-button auto-craft
  behavior is removed.
- `RecipeDatabase` has station and exact ingredient-match helpers for future small
  crafting UI work.
- The shop cauldron still passes its tiny ordered recipe list into the panel so the
  duplicate Moonleaf + Forest Water recipes remain playable: Root-Wake Tonic is chosen
  first only while Sage's quest is active/ready and the tonic is not already held.
- No new ingredients, recipe discovery, quality, traits, or recipe book UI were added.
- Follow-up `docs/plans/vertical_slice_0_3_1_known_recipe_cauldron_ui.md` replaced the
  raw ingredient-selection panel with a known-recipe list and quantity selector.
