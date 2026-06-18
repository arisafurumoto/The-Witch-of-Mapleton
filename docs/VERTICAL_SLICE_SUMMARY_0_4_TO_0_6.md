# Vertical Slice Summary - 0.4 to 0.6

> Handoff summary for Quest Guidance, Shop Browsing, and Home/Recipe Progression.
> Current through commit `8cadb64`.

## Milestone Status

- **0.4 - Quest and Recipe Guidance v1:** complete.
- **0.5 - Shop Browsing Prototype v1:** complete.
- **0.6 - Home Layout and Recipe Progression v1:** complete.
- **0.7 - Camellia's First Request and Quest Chaining v1:** planned in
  `docs/plans/vertical_slice_0_7_camellia_quest_chaining.md`.

## What 0.4 Added

- The active quest tracker derives ingredient progress from the quest turn-in item and
  its matching recipe.
- Root-Wake Tonic shows Dewcap Mushroom and Glowberry progress while it is not held.
- The tracker switches to `Bring Root-Wake Tonic to Sage` after crafting.
- Gatherables show item-name/quantity HUD toasts.
- Dewcap Mushroom and Glowberry received native 16x16 inventory icons.

## What 0.5 Added

- One persistent display stocks or returns one Calming Tea.
- The shop sign starts one deterministic customer session.
- The generic customer enters, browses the display, reserves its stock, routes around
  the counter, waits for checkout, pays, and leaves.
- Reserved stock disappears visually but is consumed only after successful checkout.
- Day advancement cancels transient reservation while preserving stable display stock.
- Customer and Sage movement use authored doorway/waypoint routes rather than
  navigation/pathfinding.
- Sleeping now uses a full-screen fade and centred new-day announcement.

## What 0.6 Added

### Home layout

- `ShopInterior.tscn` is a compact 720x480 scene with three doors:
  - top-centre forest transition;
  - bottom-centre visitor-only front door;
  - upper-right bedroom transition.
- `MarigoldRoom.tscn` is a compact 540x360 temporary bedroom shell with a 1.2 camera
  zoom, left-wall shop door, bed, player, and Saffron.
- The bed no longer exists in the shop. Sleeping and saving work from the bedroom.
- Background source PNGs remain untouched and are scaled only at display time with
  Nearest filtering.

### Shop layout and visitors

- The counter remains central. Its final collider is 96x32 and covers only the visible
  lower base.
- The cauldron sits behind/north of the counter on Marigold's working side.
- The display sits in the customer/front half, outside the direct entrance aisle.
- Sage and the generic customer both use the centred counter position `(360, 260)` at
  different times; Sage faces north toward the counter when idle.
- Both NPCs turn to face Marigold when dialogue begins.
- Sage and the customer enter and leave through the front visitor door.
- While Sage is present he belongs to `closed_shop_visitors`; the shop sign reads
  `Visitor here` and refuses to start a browsing-customer session.

### Companion transitions

- Saffron detects scene transitions and spawns 48 pixels behind Marigold using her
  arrival facing.
- He therefore appears to follow Marigold through forest, shop, and bedroom doors
  instead of walking from each scene's default cat position.

### Persistent shop state

- `ShopState` owns stable display records independently of loaded scenes.
- `ShopDisplay` reads/writes its record by stable `display_id`.
- Saves made while the shop is unloaded preserve display stock.
- Only `item_id` and `quantity` persist. Reservations and customer movement remain
  transient.
- Existing 0.5 `shop_displays` save data remains compatible.

### Recipe knowledge

- `RecipeKnowledgeSystem` tracks permanent quest-earned recipe IDs.
- Recipes with `known_by_default: true` are derived from recipe data and are not stored
  redundantly.
- Root-Wake Tonic is not default-known. It is temporarily visible while Sage's quest is
  active/ready and becomes permanently known when the quest completes.
- Quest recipes are capped to one batch only while their quest is active/ready.
- The HUD displays `Recipe learned: Root-Wake Tonic` for a new unlock.
- Completed 0.5 Sage saves silently migrate the recipe reward without replaying gold,
  items, dialogue, or toasts.

## Current Save Shape

Save version is `0.6.0`. Stable saved fields are:

- `day`
- `inventory`
- `gold`
- `gatherables_depleted`
- `quests`
- `known_recipes`
- `shop_displays`
- `current_scene`
- `player_position`

Unknown fields are ignored and missing fields use safe defaults. UI state, open-shop
sessions, customer movement, and display reservations are not saved.

## Current Autoload Additions

- `RecipeKnowledgeSystem` loads after `RecipeDatabase`.
- `ShopState` owns scene-independent shop stock.
- `SaveSystem` remains last so every system it restores is ready.

See `project.godot` and the Architecture section of `docs/PROGRESS.md` for the full
autoload order.

## Verification

Run:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_0_6.gd
```

The focused 0.6 check covers scene topology, room/shop sizes, door targets, front-door
blocking, counter collision, visitor positions/facing, Saffron transition placement,
shop stock across unloads, default/permanent recipe knowledge, Sage completion, and
completed-0.5 recipe migration.

## Intentional Limits

- No shop exterior or village map.
- No room decoration, storage, cooking, or wardrobe system.
- One display, one browsing customer, and one deterministic sale per day.
- No price setting, preferences, reputation, schedules, or navigation AI.
- No quest journal, recipe book, item quality, or traits.
- No relationships, romance, farming, restaurant gameplay, or additional region.

These are not unfinished 0.6 work. They require focused future milestones.
