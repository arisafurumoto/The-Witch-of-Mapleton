# Vertical Slice 0.5 - Shop Browsing Prototype v1

> Status: IN PROGRESS.
> Start after Vertical Slice 0.4.

## Goal

Start replacing the temporary manual customer sale with a small prototype of the
final-game shop shape described in `docs/GDD.md`: the player stocks a display, opens the
shop, a customer browses, chooses an item, brings it to the counter, and Marigold
confirms the sale.

## Required Scope

Keep this first pass deterministic and tiny:

- One display spot in the shop.
- One stockable item: Calming Tea.
- One customer.
- One open-shop interaction.
- Customer walks to the display, waits briefly, then chooses the item.
- Customer walks to the counter.
- Player interacts with the customer at the counter to complete the sale.
- Display stock is consumed and gold is awarded.

## Current First Pass

- `ShopDisplay` can stock or return one Calming Tea from inventory.
- Display stock is saved and restored by stable display id.
- Sleeping preserves stocked display items across days; an in-progress reservation is
  cancelled so the item reappears on the display after the day transition.
- The shop sign now starts the prototype shop session.
- The generic customer enters only after the shop is opened with a stocked display.
- The customer walks in through the shop door using four-direction walking art, visits
  the display, then walks to the counter and waits for checkout.
- Sage also enters through the shop door and returns to it after his quest is completed.
- A shared interior doorway waypoint keeps both NPC routes inside the visible opening
  before they turn toward their destinations.
- Buying customers route around the counter, wait on its public side facing Marigold,
  and can be attended while Marigold stands behind the counter.
- When the customer chooses an item it becomes reserved and disappears from the display;
  the underlying stock is consumed only when Marigold completes checkout.
- Sage enters only when first offering his quest; returning from the forest while his
  quest is in any unfinished state leaves him stationed at his shop position.
- `ShopSystem.complete_display_sale()` awards gold for already-stocked display items.

## Non-Goals

Do not add yet:

- Display placement UI.
- Price setting.
- Multiple displays.
- Multiple customers.
- Customer preferences.
- Browse/buy/leave probability.
- Shop open/closed schedules.
- Reputation.
- Shop upgrades.
- Full pathfinding.

## Manual Test Plan

1. Start a new game.
2. Gather Moonleaf x2 and Forest Water x1.
3. Brew Calming Tea at the cauldron.
4. Interact with the display near the counter to stock Calming Tea.
5. Sleep or save/continue after stocking to confirm the display keeps the tea.
6. Interact with the shop sign to open the shop.
7. Confirm the customer walks in through the door, visits the display, then walks to the counter.
8. Interact with the customer at the counter.
9. Confirm Calming Tea is removed from the display and 18 gold is awarded.
10. Confirm the customer walks back through the door after checkout.
11. Sleep and confirm the screen fades out, announces the new day, then fades back in.

## Known Follow-Ups

- The display uses placeholder polygon art.
- Customer movement is straight-line tweening, not navigation.
- Customer browsing/checkout state is not saved; loading restarts from the stocked display.
- There is still only one deterministic customer sale per day.
