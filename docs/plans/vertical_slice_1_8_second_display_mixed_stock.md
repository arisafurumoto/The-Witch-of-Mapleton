# Vertical Slice 1.8 - Second Display and Mixed Shop Stock v1

> Status: IMPLEMENTED, headless-verified; needs manual acceptance.

## Goal

Let Marigold stock two small shop displays at once so learned sellable recipes matter in
normal shop play.

This should extend the existing deterministic one-customer-at-a-time shop loop, not
turn the shop into a larger simulator.

## Required Scope

- Add a second shop display in `ShopInterior`.
- Give it a separate stable display ID and independent saved stock.
- Let each display hold its own stack of one sellable crafted item.
- Let the shop open sign start a queue from total available display stock.
- Let each customer choose one stocked display deterministically.
- Preserve sequential customers, one sale at a time, and existing checkout dialogue.

## Implementation Notes

- Reuse `ShopDisplay.gd` and `ShopState`.
- Keep `display_path` exports for compatibility with old scenes and verifiers.
- Prefer group scanning over a larger shop-display manager.
- Deterministic display choice should be simple, such as sorted stable display ID among
  displays with available stock.

Implemented:

- Added `SecondShopDisplay` with stable ID `side_display`.
- Kept `ShopState` as the persistence owner for all display IDs.
- Updated `ShopOpenSign` to total available stock across `shop_displays`.
- Updated `CustomerNPC` to choose, reserve, and consume from stocked displays by stable
  display ID.
- Kept the queue sequential and capped by total displayed stock, up to three customers.
- Feedback polish: added `DisplayStockPanel` so the player chooses which carried
  sellable good to stock, and added a take-back action for unreserved display stock.
- Feedback polish: added a Forest Path brook water source to make Forest Water easier to
  gather during testing.
- Deferred the time system to a dedicated future slice because shop hours, day timing,
  save data, UI, and NPC timing should be handled together.

## Verification Plan

Add `tools/verify_vertical_slice_1_8.gd`.

The verifier should check:

- `ShopInterior` has two shop displays with different display IDs.
- `ShopState` saves and restores both display stocks independently.
- The shop open sign sees stock from either display.
- A customer can buy from the second display when it is the only stocked display.
- A customer queue can sell from both displays across one shop session.
- Existing 0.9 one-display stack behavior still works.

Verification result:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_8.gd
```

Passed.

Feedback verifier:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_8_1.gd
```

Passed.

## Manual Acceptance Test

1. Craft or grant two different sellable goods, such as Calming Tea and Glowberry
   Cordial.
2. Stock one display with each good.
3. Open the shop.
4. Serve customers and confirm each sale removes one item from the chosen display and
   grants the correct gold.
5. Save/load and confirm both display stocks persist independently.

## Non-Goals

- Price setting.
- Customer preferences.
- Multiple simultaneous customers.
- Shop upgrades.
- Direct inventory sales.
- Decoration mode.
- Customer schedules or relationship effects.
