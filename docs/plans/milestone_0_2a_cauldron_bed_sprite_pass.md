# Milestone 0.2a: Cauldron And Bed Sprite Pass

> **Status: DONE (2026-06-16).** `art/props/shop/{cauldron,bed}.png` added (native
> 72×56 / 72×44, scale 1.0); `ShopInterior.tscn` `Visual` polygons swapped for
> `Sprite2D` nodes with base aligned to origin; zones/scripts/collision unchanged.
> Import + headless parse passed clean.

## Summary

Replace the two most important shop placeholders, the cauldron and bed, with simple pixel-art sprites while preserving all existing interaction, collision, crafting, sleep, save, and day-advance behavior.

## Implementation Changes

- Add two new shop prop assets:
  - `art/props/shop/cauldron.png`, target about `72x56` on-screen so it reads as a large witch's cauldron.
  - `art/props/shop/bed.png`, target about `72x44` on-screen.
  - Use simple readable pixel art, not a full environment polish pass.
- Update `scenes/world/ShopInterior.tscn`:
  - Replace `Cauldron/Visual` `Polygon2D` with a `Sprite2D`.
  - Replace `Bed/Visual` and `Bed/Pillow` polygons with one `Sprite2D`.
  - Keep the existing `Area2D` nodes, scripts, prompts, positions, and collision shapes.
  - Align sprite feet/base to the node origin so Y-sort stays correct.
- Do not change crafting logic, sleep logic, save/load, inventory, customer flow, or forest gathering.

## Public Interfaces

- No new JSON schemas, autoloads, save fields, scripts, recipes, items, or systems.
- Only scene visual nodes and new art assets should change.

## Test Plan

- Run Godot import after adding PNGs.
- Run the headless project parse check and confirm no `ERROR` lines.
- Manual test:
  - Start in `scenes/world/ShopInterior.tscn`.
  - Confirm cauldron and bed render crisply at game scale.
  - Interact with cauldron before and after gathering ingredients.
  - Sleep in the bed and confirm day advances and save still works.
  - Complete the full First Potion Sale loop once.

## Assumptions

- The next step should remain inside the completed vertical slice, not expand systems yet.
- Placeholder rectangles elsewhere, including sign, customer, walls, floor, and forest tiles, remain unchanged.
