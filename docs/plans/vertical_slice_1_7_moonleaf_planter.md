# Vertical Slice 1.7 - Moonleaf Planter v1

> Status: IMPLEMENTED, headless-verified; needs manual acceptance.

## Goal

Pay off Sage's Moonleaf Seed Packet reward with one tiny fixed planter interaction on
the shop property.

This is not a farming system. It is a single authored planter that lets Marigold plant
one `moonleaf_seed_packet`, sleep through simple growth stages, and harvest a small
amount of `moonleaf`.

## Required Scope

- Add one interactable Moonleaf planter at the existing shop exterior garden marker.
- Consume one `moonleaf_seed_packet` when planting.
- Advance growth by current day after sleeping.
- Show simple visible stages: empty, sprout, young, ready, harvested.
- Harvest Moonleaf x2 once the planter is ready.
- Save and restore planter state.
- Keep existing shop exterior transition, collision, Saffron, and visual readability
  behavior intact.

## Implementation Notes

- Use a tiny `PlanterSystem` autoload for the one stable planter state.
- Keep the existing `FuturePlanterMarker` visual-only so 1.6's visual preservation
  checks remain meaningful.
- Add the interactable planter as a separate sibling over the marker rather than turning
  the marker itself into a behavior node.
- Do not add crop data files, crop grids, watering, tools, stamina, quality, seasons, or
  seed shops.

Implemented:

- Added `PlanterSystem` with one stable ID: `moonleaf_planter_001`.
- Added `MoonleafPlanter` on `ShopExterior`, as a sibling to the still-visual-only
  `FuturePlanterMarker`.
- Added small sprout, young, ready, and harvested growth sprites.
- Added planter save/load under the `planters` save key.
- Planting consumes `moonleaf_seed_packet` x1; ready harvest gives `moonleaf` x2.
- Feedback polish: the ready/mature stage now uses the existing
  `art/props/forest/moonleaf_bush.png` art, while sprout and young stages keep their
  smaller planter-specific sprites.

## Verification Plan

Add `tools/verify_vertical_slice_1_7.gd`.

The verifier should check:

- `PlanterSystem` exists and starts empty for a new game state.
- The shop exterior has `MoonleafPlanter`.
- The existing `FuturePlanterMarker` remains visual-only.
- Planting consumes one `moonleaf_seed_packet`.
- Growth stage changes after day advancement.
- Harvesting ready Moonleaf grants Moonleaf x2.
- Save data includes and restores planter state.
- Existing shop exterior doors and Saffron nodes remain present.

Verification result:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_7.gd
```

Passed.

## Manual Acceptance Test

1. Complete Sage's first request or add a Moonleaf Seed Packet through a test save.
2. Walk to the shop exterior garden corner.
3. Interact with the planter and confirm the seed packet is consumed.
4. Sleep until the Moonleaf is ready.
5. Return to the planter and harvest Moonleaf.
6. Save/load and confirm the planter keeps its current stage.

## Non-Goals

- Full farming.
- Watering tools.
- Crop grids.
- Weather.
- Seasons.
- Greenhouse.
- Seed shop.
- Fertilizer.
- Crop quality.
- Tool stamina.
