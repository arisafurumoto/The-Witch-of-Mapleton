# Vertical Slice 0.3.1 - Known Recipe Cauldron UI

> Status: DONE (2026-06-17).

## Goal

Make cauldron crafting clearer by showing known recipes directly instead of asking the
player to manually combine ingredients.

## Implemented Scope

- The cauldron panel shows known cauldron recipes.
- Recipes that cannot be made with current inventory can still be selected for preview.
- Brew is disabled until the selected recipe's ingredients are held.
- Selecting a recipe shows its output and ingredient requirements.
- The player can choose how many batches to brew with `-` and `+`.
- Quantity is capped by available ingredients.
- Quest-gated recipes, such as Root-Wake Tonic, only appear while their quest is
  active/ready and are capped to one brew.
- Batch brewing uses `CraftingSystem.craft_quantity()` so ingredients are validated
  before anything is consumed.
- Follow-up content pass added Dewcap Mushroom and Glowberry gatherables, then changed
  Root-Wake Tonic to use those ingredients instead of Calming Tea's Moonleaf + Forest
  Water mix.

## Non-Goals

- No recipe discovery.
- No quality, traits, grades, or substitutions.
- No full recipe book UI.
- No extra recipes beyond the existing Calming Tea and Root-Wake Tonic.
- No economy changes.
