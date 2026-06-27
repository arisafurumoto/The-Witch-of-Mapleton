# Vertical Slice Roadmap - Current Direction

> Status: ROUGH ROADMAP.
> Last updated: 2026-06-28.
> This is a direction-setting document, not a commitment to implement every detail in
> order. Each slice still needs its own focused plan before implementation.

## North Star

The near-term direction is **Marigold's first week in Mapleton**.

The game should grow from the completed First Potion Sale loop into a small authored
week where Marigold:

- helps Sage and Camellia through a short quest chain;
- unlocks one tiny new gathering space;
- learns a few useful recipes;
- sells those crafted goods in a slightly more capable shop;
- starts to feel connected to Mapleton without needing a full village, schedule,
  relationship, farming, or economy system yet.

The core loop we are building toward is:

```text
Quest need -> gather ingredients -> craft recipe -> deliver or sell item -> unlock
new recipe, place, shop capability, or village detail
```

## Guiding Rules

- Keep progression authored and quest-driven.
- Add one new system pressure at a time.
- Prefer tiny playable loops over broad feature shells.
- Use the notebook, notice board, cauldron, inventory, save/load, and shop display
  systems that already exist.
- Add reusable data or scripts only when duplication becomes concrete and annoying.
- Keep the village implied through one or two useful spaces before adding a full town.
- Keep farming, seasons, relationships, quality/traits, schedules, combat, and shop
  pricing out until a specific slice truly needs them.

## Near-Term Slice Sequence

### Vertical Slice 1.3 - Forest Path Unlock and Brookmint Tea v1

Detailed plan: `docs/plans/vertical_slice_1_3_forest_path_brookmint.md`.

Purpose:

- Prove quest-gated world expansion.
- Add one tiny `ForestPath` scene.
- Add one new ingredient, `brookmint`.
- Add one new recipe, `brookmint_tea`.
- Add one Camellia request that uses the new area and recipe.

Why it matters:

- It makes quest completion open the world, not just add another delivery.
- It tests whether the existing transition, Saffron, gatherable, recipe, notebook, and
  save systems are ready for small authored regions.

### Vertical Slice 1.4 - Second Display and Mixed Shop Stock v1

Rough goal:

- Make learned recipes matter in normal shop play by letting Marigold stock two small
  displays at once.

Possible scope:

- Add a second shop display.
- Let each display hold its own stack of one item.
- Let the existing customer queue buy from either stocked display.
- Keep display stock persistent through `ShopState`.
- Keep checkout deterministic.

Non-goals:

- Price setting.
- Customer preferences.
- Multiple simultaneous customers.
- Shop upgrades.
- Direct inventory sales.
- Decoration mode.

Why it likely comes after 1.3:

- By then Marigold may know Calming Tea, Glowberry Cordial, Root-Wake Tonic, and
  Brookmint Tea. A single display will start to feel too narrow.

### Vertical Slice 1.5 - Simple Customer Variety and Display Choice v1

Rough goal:

- Make the shop feel a little less mechanical while still staying deterministic.

Possible scope:

- Add simple customer variants using existing or placeholder art.
- Give customers short data-driven lines that mention the item they picked.
- Let a customer choose between available displayed goods using a tiny deterministic
  priority rule, such as first display with stock or highest sell price.
- Keep the queue sequential and small.

Non-goals:

- Customer schedules.
- Relationship points.
- Reputation.
- Complex preferences.
- Price sensitivity.
- Simultaneous browsing.

Why it matters:

- It makes the shop loop start paying off the recipe chain without building a shop
  simulator too early.

### Vertical Slice 1.6 - Mapleton Lane Ambient Dialogue v1

Rough goal:

- Make Sage and Camellia feel present in town after their requests, without adding
  schedules or relationships.

Possible scope:

- Add a few short post-quest ambient lines for Sage and Camellia in Mapleton Lane.
- Let lines vary by completed quest or current active request.
- Consider a tiny dialogue lookup file only if inline quest data becomes awkward.
- Keep interactions read-only unless a quest is active/ready.

Non-goals:

- Full NPC database.
- Daily schedules.
- Portraits.
- Gifts.
- Relationship UI.
- Branching dialogue.

Why it matters:

- It gives the existing town space emotional texture before the map expands.

### Vertical Slice 1.7 - Moonleaf Seed Packet Payoff v1

Rough goal:

- Pay off Sage's Moonleaf Seed Packet reward with the smallest possible plant-growing
  interaction.

Possible scope:

- Add one pot or tiny planter in Marigold's room or shop exterior.
- Let the player plant one Moonleaf Seed Packet.
- Advance growth through sleep/day changes.
- Harvest a small amount of Moonleaf.

Non-goals:

- Full farming.
- Watering tools.
- Crop grids.
- Seasons.
- Seed shop.
- Fertilizer.
- Farm expansion.

Why it is later, not immediate:

- Farming is a long-term feature and a scope risk. It should only appear as a tiny
  reward payoff once the quest/crafting/shop loop is sturdier.

### Vertical Slice 1.8 - First Week Wrap and Next Goal v1

Rough goal:

- Give the first week a small sense of completion and point toward the next phase.

Possible scope:

- Add a short Saffron or town-board beat after the early Sage/Camellia chain.
- Summarize that Marigold is becoming useful to Mapleton.
- Point toward one next larger objective, such as restoring a forest bridge, opening a
  plant-shop interior, or preparing the shop for more customers.

Non-goals:

- Cutscenes with custom art.
- Multiple endings.
- Branching story.
- Relationship arcs.
- A full chapter system.

Why it matters:

- It gives the current vertical-slice chain an emotional landing instead of just adding
  requests forever.

## Direction After The First Week

After slices 1.3-1.8, choose the next direction based on what feels weakest in play:

- If the **shop** feels thin, move toward more displays, simple customer types, and
  eventually gentle pricing.
- If **gathering** feels thin, add another tiny authored area and a small recipe chain.
- If **Mapleton** feels empty, add ambient dialogue and one more static villager before
  schedules.
- If **progression** feels unclear, improve the notebook/HUD before adding more content.
- If the **daily rhythm** feels too unlimited, consider a gentle time/stamina prototype,
  but only after the core loops are fun without it.

## Systems To Keep Deferred

These are still real long-term goals, but not next-slice work:

- Full town map.
- NPC schedules.
- Relationship and romance systems.
- Full farming.
- Seasons/calendar mechanics.
- Combat, HP, and stamina.
- Item quality and traits.
- Shop price setting and economy simulation.
- Cafe/cooking.
- Homunculi.
- Ancient region.

## Current Recommendation

Implement 1.3 next, then pause for a manual playthrough before deciding whether 1.4
should push the shop loop or whether the new forest path needs polish first.
