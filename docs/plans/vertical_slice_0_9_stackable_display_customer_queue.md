# Vertical Slice 0.9 - Stackable Display and Customer Queue v1

> Status: PLANNED.
> Start after Vertical Slice 0.8 is manually accepted and the current work is safely
> committed or otherwise backed up.

## Goal

Deepen the shop loop by letting Marigold stock multiple copies of one displayed item and
serve a short sequence of customers from that display stock.

This keeps the rule that only displayed items can be sold. Customers should never buy
items directly from Marigold's inventory. The display remains the source of truth for
what is for sale.

This slice should make the 0.7 Glowberry Cordial recipe matter in normal shop play
without adding the town, deliveries, customer preferences, price setting, schedules, or
a full shop-management simulation.

## Design Decision From Planning

The earlier idea, **First Posted Request**, is parked for later. The user wants posted
or requested deliveries to end with Marigold giving the item to the requester in person,
which needs at least a tiny town/delivery space. Do not implement mailbox turn-ins or
anonymous request-board completion before that exists.

## Player Flow

1. Craft multiple copies of a sellable crafted item.
2. Interact with the shop display.
3. Stock one copy of a crafted item, such as Calming Tea or Glowberry Cordial.
4. Interact again to add more copies of the same item to the display stack.
5. Open the shop at the sign.
6. A customer enters, chooses one displayed item, walks to the counter, and waits.
7. Marigold checks them out; the customer pays and leaves.
8. If display stock remains, the next customer enters and repeats the same flow.
9. The customer sequence stops when the display is empty or the small planned queue has
   finished.
10. Sleep/save/continue and confirm remaining display stock persists.

## Required Scope

### Stackable display stock

- Keep one display area for this slice.
- A display may contain:
  - one item ID;
  - quantity greater than 1.
- Do not allow mixed item types on one display yet.
- If the display is empty, the player can stock one sellable crafted item from
  inventory.
- If the display already has the same item, interacting should add one more copy from
  inventory.
- If the display already has a different item, show a small HUD message and do not
  replace it automatically.
- Display quantity should decrease by 1 per completed sale.
- When quantity reaches 0, the display becomes empty.
- Existing persistent `ShopState` save shape should be enough:

```json
{
  "main_display": {
    "item_id": "calming_tea",
    "quantity": 3
  }
}
```

- Do not change the save version unless the implementation changes the save shape.

### Display visuals and prompts

- Keep visuals simple and readable.
- Show the stocked item icon while quantity is above 0.
- Add a small quantity label near the icon, such as `x2` or `x3`.
- Hide the quantity label when the display is empty.
- Suggested prompt behavior:
  - empty display: `Stock display`
  - same item in inventory: `Add stock`
  - no matching inventory: `Display stocked`
  - reserved by customer: keep current reserved/hidden behavior or show a simple
    unavailable prompt.
- Use the existing item icons and fallback behavior. Do not add new art for this slice.

### Sellable item choice

- Allow stocking known crafted items that make sense as shop goods.
- At minimum, support:
  - `calming_tea`
  - `glowberry_cordial` after Camellia's quest unlocks it
- If implementation needs a simple filter, prefer data already present:
  - item category;
  - recipe output;
  - known recipe state;
  - positive sell price.
- Do not add a new shop-catalog database unless the current data cannot support the
  small slice cleanly.

### Customer queue v1

- Multiple customers are allowed only as a simple sequential queue.
- Only one customer should be active in the scene at a time.
- Customer flow remains:
  - enter through the existing visitor/front-door markers;
  - walk to the display;
  - reserve one displayed item;
  - walk to the public side of the counter;
  - wait for checkout;
  - leave through the front door.
- After checkout and exit, if display stock remains, spawn/start the next customer.
- The queue size should be tiny and deterministic.
  - Suggested first pass: queue count equals the display quantity when the shop opens,
    capped at 3.
  - Example: display has 5 items, up to 3 customers arrive in that shop session.
  - Example: display has 2 items, 2 customers arrive.
- A customer buys one item.
- The session ends when the planned queue is served or display stock is empty.
- Do not preserve an active queue through save/load; only persistent display stock
  should survive. Active customer/session state remains transient.

### Customer data and dialogue

- Reuse the existing generic customer art and scene for the queue.
- It is acceptable for each sequential customer to be visually identical in this slice.
- Keep dialogue minimal and data-driven through the existing `data/shop_requests.json`
  path where practical.
- If the current request data assumes only Calming Tea, update it so customer dialogue
  can refer to the selected display item name without hard-coding each sellable item.
- Do not add customer preferences, different customer types, names, portraits,
  schedules, relationship flags, or town reputation.

### Sale price and rewards

- Sale price should come from `ItemDatabase.get_sell_price(item_id)`.
- Checkout should award the displayed item's sell price.
- Confirm Glowberry Cordial sells for its current item sell price.
- Do not add price-setting UI, haggling, discounts, satisfaction, or balance economy
  systems.

### Shop sign and closed-shop visitors

- Preserve the existing `closed_shop_visitors` behavior.
- If Sage or Camellia is present, the shop sign should still refuse to open browsing.
- Opening the shop should fail gracefully if the display is empty.
- Starting a customer queue should reserve customers only from display stock, not from
  inventory.

### Verification

- Add `tools/verify_vertical_slice_0_9.gd`.
- The verifier should check:
  - the display can store quantity above 1 in `ShopState`;
  - `ShopDisplay` restores stacked stock from save/global state;
  - the display quantity label exists and updates for stocked/empty states;
  - stocking the same item increments quantity and removes inventory;
  - trying to stock a different item does not overwrite existing stock;
  - sale completion decrements stock by exactly 1 and awards that item's sell price;
  - opening the shop with display quantity 2 or 3 creates a sequential customer plan;
  - no more than one customer is active at once;
  - the next customer begins only after the previous one leaves;
  - 0.8 front-door visitor markers and transitions still load.

## Implementation Order

1. Run focused 0.6, 0.7, and 0.8 verifiers.
2. Inspect current `ShopDisplay.gd`, `ShopState.gd`, `ShopSystem.gd`,
   `CustomerNPC.gd`, and `data/shop_requests.json`.
3. Add display quantity-label support.
4. Update display stocking to stack one copy at a time for the same item.
5. Allow stocking Glowberry Cordial once its recipe is known and the item is in
   inventory.
6. Update customer reservation/checkout so each customer consumes exactly one display
   item.
7. Add a tiny sequential queue coordinator using the smallest change to the current
   customer/shop system.
8. Keep active queue state transient.
9. Add `tools/verify_vertical_slice_0_9.gd`.
10. Run 0.6, 0.7, 0.8, and 0.9 focused verifiers.
11. Update `docs/PROGRESS.md` and this plan with implementation notes.

## Acceptance Test

1. Start or continue a game with Calming Tea known.
2. Craft 3 Calming Tea.
3. Stock the display three times and confirm it shows Calming Tea `x3`.
4. Open the shop.
5. Confirm one customer enters, picks up one item, waits at the counter, and can be
   checked out.
6. Confirm gold increases by one Calming Tea sell price and display stock becomes `x2`.
7. Confirm the next customer enters only after the previous customer leaves.
8. Serve the remaining queued customers and confirm the display reaches empty.
9. Complete Camellia's request if needed, craft Glowberry Cordial, stock it, and confirm
   a customer can buy it for the Glowberry Cordial sell price.
10. Sleep, quit, and Continue; confirm any remaining display stack persists.
11. Confirm Sage/Camellia closed-shop visits still block opening the customer queue.
12. Confirm the front exterior transition and Saffron follow behavior still work.

## Non-Goals

- Selling directly from inventory.
- Mixed item types on one display.
- Multiple displays.
- Multiple simultaneous customers.
- Checkout lines or crowding.
- Customer preferences, named customers, schedules, pathfinding, reputation, or
  satisfaction.
- Price-setting, haggling, discounts, or economy rebalance.
- New recipes, ingredients, quests, NPCs, or map areas.
- Town delivery, posted requests, mailbox turn-ins, or request-board systems.
- Save/load for active customer queue state.

## Risks

- Queue behavior can grow quickly into a shop simulator. Keep it sequential and capped.
- Display reservation must not accidentally consume extra stock. Reserve and checkout
  should together reduce one item per customer.
- The display currently hides its item icon while a customer carries the reserved item;
  stacked stock may need a clear rule so remaining stock is still understandable.
- Glowberry Cordial should only become a normal shop item after the recipe is known and
  the player has crafted it.

## Success Criteria

- One display can hold a visible stack of one sellable item.
- Customers buy only displayed stock.
- Multiple customers can be served sequentially from a stocked display.
- Glowberry Cordial can participate in the normal shop loop after Camellia unlocks it.
- Existing 0.1-0.8 quest, crafting, transition, companion, save/load, and visitor flows
  remain intact.
