# Vertical Slice Roadmap - First Week, Art, and Tiny Farming

> Status: ROUGH ROADMAP.
> Last updated: 2026-07-01.
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
- starts to feel connected to Mapleton through portraits, props, map readability, and
  town texture;
- earns a first tiny plant-growing payoff without turning the game into a farm sim.

The core loop we are building toward is:

```text
Quest need -> gather ingredients -> craft recipe -> deliver or sell item -> unlock
new recipe, place, shop capability, visual detail, or tiny home-system payoff
```

## Guiding Rules

- Keep progression authored and quest-driven.
- Add one new system pressure at a time.
- Prefer tiny playable loops over broad feature shells.
- Use the notebook, notice board, cauldron, inventory, save/load, and shop display
  systems that already exist.
- Add reusable data or scripts only when duplication becomes concrete and annoying.
- Let visual production support existing playable spaces before expanding the world.
- Add portraits as dialogue support first, not as a relationship or cutscene system.
- Start farming as one controlled planter, then expand only if that tiny loop feels good.
- Keep seasons, relationships, quality/traits, schedules, combat, shop pricing, and full
  farming out until a specific slice truly needs them.

## Production Tracks

The roadmap now has three related tracks. They can alternate, but should not all become
active at once.

### Track A - Playable Slice Growth

Purpose:

- Extend the current quest, gathering, crafting, delivery, and shop loop.
- Keep each new milestone manually playable.
- Use authored requests to unlock new recipes, map pieces, and small shop capabilities.

Near-term examples:

- Forest Path Unlock and Brookmint Tea.
- Second shop display.
- Simple customer variety.
- First-week wrap beat.

### Track B - Visual and World Production

Purpose:

- Make the existing spaces feel intentional and warm.
- Replace placeholder shapes with readable pixel-art tiles and props.
- Add dialogue portraits once the dialogue box can display them cleanly.

Near-term examples:

- 128x128 dialogue portraits.
- Map blockouts for shop property, Mapleton Lane, forest spaces, and a future garden
  corner.
- Small tileset packs for forest, village, shop exterior, and garden soil/planters.
- Prop passes for the shop, forest, village lane, and garden.

### Track C - Tiny Farming

Purpose:

- Pay off Sage's Moonleaf Seed Packet reward.
- Test plant growth through the existing day/save systems.
- Keep farming useful but smaller than gathering, crafting, quests, and shopkeeping.

Near-term examples:

- One Moonleaf planter.
- Later, a 2-4 plot fixed garden patch if the planter works well.

## Recommended Slice Sequence

### Vertical Slice 1.3 - Forest Path Unlock and Brookmint Tea v1

Status: implemented and headless-verified on 2026-06-30.

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

### Vertical Slice 1.4 - Dialogue Portraits v1

Status: implemented and headless-verified on 2026-07-01.

Rough goal:

- Let the dialogue box show a 128x128 portrait for the current speaker.

Possible scope:

- Add a portrait lookup by stable speaker ID, such as `marigold`, `sage`, `camellia`,
  `generic_customer`, and `saffron`.
- Use simple paths such as `art/portraits/<speaker_id>_neutral.png`.
- Add one neutral portrait per character first.
- Keep a clean fallback for speakers without portraits.
- Preserve existing dialogue data and interaction flow.

Non-goals:

- Expression matrices.
- Relationship UI.
- Branching conversation systems.
- Visual novel cutscenes.
- Portrait animation.
- Full dialogue database rewrite.

Why it likely comes after 1.3:

- The game already has repeated dialogue with Sage, Camellia, customers, and Saffron.
  Portraits will make those moments feel more intentional before adding many more lines.

### Vertical Slice 1.5 - Map Blockout and Layout Readability v1

Rough goal:

- Decide the small playable layout language before spending time on polished map art.

Possible scope:

- Review and lightly revise the shop exterior threshold, Mapleton Lane, Forest Clearing,
  and new Forest Path.
- Mark the future tiny garden or planter location.
- Use placeholder collision, labels, and simple path shapes where needed.
- Confirm transitions, Saffron placement, NPC waiting spots, display/counter flow, and
  walkable areas still feel clear at 640x360.
- Document any future map needs instead of implementing them immediately.

Non-goals:

- Full village map.
- New town districts.
- NPC schedules.
- Minimap or map UI.
- Decoration mode.
- Large scene rewrites.

Why it matters:

- Tilesets and props are easier to produce when the screens already have a clear
  gameplay composition.

### Vertical Slice 1.6 - Tileset and Prop Production Pass v1

Rough goal:

- Replace the most visible placeholders with small, reusable art packs that support the
  current maps.

Possible tileset scope:

- Forest ground, path edges, small grass details, and brook/soft-water edge tiles.
- Village path, grass, fence, flower border, and small curb/step tiles.
- Shop exterior wall, roof edge, doorstep, sign backing, and window detail tiles.
- Garden soil, planter, pot, trellis, and edging tiles.

Possible prop scope:

- Shop: shelves, jars, hanging herbs, crates, rug, lanterns, paper tags, bundled twigs.
- Forest: mushrooms, stones, logs, wildflowers, moss patches, tiny magical glints.
- Mapleton Lane: signposts, market crates, flower tubs, benches, restaurant stall
  details, Sage plant-stall details.
- Garden: seed sacks, watering can, compost bin, small tools, empty pots.

Implementation rule:

- Replace visible placeholders without adding new mechanics unless the current slice
  specifically asks for them.

Non-goals:

- Full decoration system.
- Animated environment system.
- Weather.
- Seasons.
- Large tileset atlas tooling.
- Final art for every map.

Why it matters:

- This is where the project can start feeling handcrafted without pulling new systems
  forward too early.

### Vertical Slice 1.7 - Moonleaf Planter v1

Rough goal:

- Pay off Sage's Moonleaf Seed Packet reward with the smallest possible plant-growing
  interaction.

Possible scope:

- Add one pot or tiny planter in Marigold's room, shop exterior, or a marked garden
  corner.
- Let the player plant one `moonleaf_seed_packet`.
- Advance growth through sleep/day changes.
- Show simple growth stages.
- Harvest a small amount of `moonleaf`.
- Save and restore the planted/growth/harvest state.

Non-goals:

- Full farming.
- Watering tools.
- Crop grids.
- Weather.
- Seasons.
- Greenhouse.
- Fruit trees.
- Seed shop.
- Fertilizer.
- Farm expansion.
- Crop quality.
- Tool stamina.

Why it is later, not immediate:

- Farming is a long-term feature and a scope risk. It should appear as a tiny reward
  payoff once the quest/crafting/shop loop and map readability are sturdier.

### Vertical Slice 1.8 - Second Display and Mixed Shop Stock v1

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

Why it likely comes after the planter:

- By then Marigold should have enough recipes and ingredient sources that a single
  display may feel too narrow.

### Vertical Slice 1.9 - Simple Customer Variety and Display Choice v1

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

### Vertical Slice 1.10 - Mapleton Lane Ambient Dialogue v1

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
- Gifts.
- Relationship UI.
- Branching dialogue.

Why it matters:

- It gives the existing town space emotional texture before the map expands further.

### Vertical Slice 1.11 - Tiny Garden Patch v1

Rough goal:

- Expand the Moonleaf planter into a still-small fixed garden if the first plant loop is
  fun and stable.

Possible scope:

- Add 2-4 fixed soil plots outside the shop or in a small garden corner.
- Support one or two seed types using simple data, such as seed item ID, crop item ID,
  days to grow, stage visuals, and harvest quantity.
- Reuse day advancement and save/load.
- Let garden harvests feed existing or near-term recipes.

Non-goals:

- Freeform crop grids.
- Hoeing or tilling.
- Watering stamina.
- Seasonal crop lockouts.
- Sprinklers.
- Fertilizer.
- Farm animals.
- Farm upgrades.

Why it matters:

- It tests whether limited farming can support the witch-shop loop without becoming the
  main game.

### Vertical Slice 1.12 - First Week Wrap and Next Goal v1

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

## Asset Planning Notes

### Portraits

V1 portrait set:

- `marigold_neutral`
- `sage_neutral`
- `camellia_neutral`
- `generic_customer_neutral`
- `saffron_neutral`, if Saffron continues to have dialogue in this phase

Later portrait set:

- gentle smile
- concerned
- thinking
- surprised
- happy

Keep portrait art separate from runtime walking sprites. Do not crop, resize, recolor,
or repaint user-supplied portrait exports in place.

### Map Designs

Near-term map design should focus on:

- Marigold's shop interior and room as the home base.
- Shop exterior as a tiny threshold with space for a future planter or garden corner.
- Mapleton Lane as a readable first village screen with Camellia, Sage, and the board.
- Forest Clearing and Forest Path as compact gathering screens with clear exits and
  ingredient silhouettes.

Full-town planning can exist as sketches or notes, but should not become implementation
until Mapleton Lane feels good.

### Prop Designs

Props should communicate function first:

- Shop props should say "witch shop", "handmade", and "sellable goods".
- Forest props should say "gathering", "wild magic", and "safe but mysterious".
- Village props should say "small community", "restaurant", "plant stall", and "notice
  board".
- Garden props should say "small home growing space", not "large farm".

### Tilesets

Build small tileset groups around active scenes:

- Forest spring tiles.
- Village lane tiles.
- Shop exterior tiles.
- Garden/planter tiles.
- Interior variation tiles only after the shop layout stops moving.

Avoid making a huge all-purpose tileset before the maps have settled.

### Farming

The farming path should be:

```text
Moonleaf Seed Packet reward -> one planter -> tiny fixed garden -> seed source ->
simple sunny/rainy/snow weather -> seasonal outside crops -> greenhouse ->
fruit trees -> magical watering automation -> animal farm / monster farm much later
```

The first implementation should probably store:

- stable planter ID
- planted seed item ID
- output crop item ID
- planted day or growth day count
- days needed to grow
- harvested/empty state

Later farming implementation notes:

- Weather should be weighted so sunny days are much more common than rainy days.
- Winter uses snow instead of rain, with the same outside-watering benefit for outside
  winter crops.
- The radio should eventually provide a weather forecast.
- Outside crops die immediately on the first day of a new season if they are no longer
  in season.
- Greenhouse crops can grow in any season but need manual watering until automated.
- The first sprinkler-like magical watering item is **Nuage**, a small magical cloud
  named from the French word for cloud. Its mechanical rule is 3x3 coverage in the
  morning while floating above the center tile, leaving that center planting space
  usable.
- Fruit trees use the grid, take a 3x3 area, take one season to mature, and can be
  replanted; removing one from its current spot uses an axe.
- Farming automation should progress from manual watering, to sprinkler-like magical
  items, to homunculi that can water and eventually harvest.

## Direction After The First Week

After the 1.3+ roadmap, choose the next direction based on what feels weakest in play:

- If the **shop** feels thin, move toward more displays, simple customer types, and
  eventually gentle pricing.
- If **gathering** feels thin, add another tiny authored area and a small recipe chain.
- If **Mapleton** feels empty, add ambient dialogue and one more static villager before
  schedules.
- If **progression** feels unclear, improve the notebook/HUD before adding more content.
- If **daily rhythm** feels too unlimited, consider a gentle time/stamina prototype, but
  only after the core loops are fun without it.
- If **farming** feels promising, expand one planter into a tiny fixed garden before any
  full farming mechanics.

## Systems To Keep Deferred

These are still real long-term goals, but not next-slice work:

- Full town map.
- NPC schedules.
- Relationship and romance systems.
- Full farming.
- Large property building/upgrade systems.
- Simple weather.
- Radio weather forecast.
- Greenhouse.
- Fruit trees.
- Farming grid and magical watering automation.
- Ordinary animal farming.
- Monster taming, monster farming, and monster-farm slots.
- Seasons/calendar mechanics.
- Combat, HP, and stamina.
- Item quality and traits.
- Shop price setting and economy simulation.
- Karazon/corporate story arcs.
- Cafe/cooking.
- Homunculi.
- Ancient region.

## Current Recommendation

Implement 1.3 next, then pause for a manual playthrough. After that, the recommended
order is:

```text
Dialogue portraits -> map blockout/readability -> tileset and prop pass ->
Moonleaf planter -> second display/shop variety
```

This keeps the current playable loop expanding while also making Mapleton look and feel
more like the cosy witch village the game wants to become.
