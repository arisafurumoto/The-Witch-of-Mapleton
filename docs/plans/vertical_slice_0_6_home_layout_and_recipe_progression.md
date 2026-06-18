# Vertical Slice 0.6 - Home Layout and Recipe Progression v1

> Status: COMPLETE (2026-06-18).
> Start after Vertical Slice 0.5.

## Goal

Extend the proven loop in two focused passes: establish the final-game-shaped home
layout (shop plus Marigold's room), then prove that authored quests can permanently
unlock recipe knowledge. Implement 0.6A before 0.6B and keep each pass independently
playable.

## 0.6A - Shop and Room Layout

### Shop layout

Use a compact 720x480 shop footprint and placeholder door openings where the existing
background art does not contain one. Scale the existing background at display time with
Nearest filtering; do not modify or resample the source background PNGs.

- Rear/top-centre door: existing player transition to the forest at approximately
  `(480, 64)`.
- Front/bottom-centre door: customer and visitor entrance. It has no destination scene
  and must not transition the player yet.
- Upper-right wall door: player transition to Marigold's room.
- Split the relevant wall collision around the new front and room door openings. No
  actor route may pass through a wall collider or visually cut across a wall corner.
- Keep the shop counter central. Place the cauldron north of/behind the counter on
  Marigold's working side.
- Move the display toward the front/customer half of the shop, clear of the direct
  entrance aisle.
- Replace the current shared rear entrance markers with front-door visitor markers.
  The generic customer and Sage enter and leave through the front door.
- Customer route remains authored and deterministic: front door -> clear-of-door
  waypoint -> display -> counter-side waypoints -> public side of counter -> front
  door. Marigold completes checkout from behind the counter.

### Marigold's room

- Add `scenes/world/MarigoldRoom.tscn` as a temporary 540x360 room shell using the
  existing shop floor/wall textures at native scale.
- Add player and Saffron instances, room boundary collision, a left-wall return door to
  the shop, and explicit transition spawn/facing values in both directions.
- Move the existing bed node and sprite out of the shop and into the room. Sleeping,
  day advancement, fade-to-black, saving, and new-day reveal retain their current
  behavior.
- Do not add room decoration, storage, cooking, wardrobe, or new room art in this pass.

### Persistent shop state

Moving the bed into a separate scene means the display will be unloaded when saving.
Complete persistence before moving the bed.

- Add a small `ShopState` autoload that owns stable display stock records independent of
  the loaded scene.
- `ShopDisplay` reads its record by `display_id` on `_ready()` and writes changes after
  stocking, returning, reserving/cancelling, or consuming stock.
- Persist only stable stock (`item_id`, `quantity`). Customer reservation and movement
  remain transient; loading restores the item visibly on its display.
- `SaveSystem` serializes/deserializes `ShopState` instead of discovering only currently
  loaded display nodes. Continue reading the existing `shop_displays` save field so 0.5
  saves remain compatible.
- New Game clears `ShopState`. Saving from either the shop or room must preserve stock.

## 0.6B - Recipe Knowledge and Quest Unlocks

### Recipe knowledge

- Add a `RecipeKnowledgeSystem` autoload with `is_recipe_known(recipe_id)`,
  `unlock_recipe(recipe_id)`, `get_save_data()`, and `load_from(data)`.
- Emit `recipe_unlocked(recipe_id)` only for a newly learned valid recipe.
- Recipes with `known_by_default: true` are always known and do not need duplicated
  save entries.
- Change Root-Wake Tonic to not be known by default. It remains temporarily visible
  while `sage_first_request` is active or ready, then becomes permanently known when
  the quest is completed.
- The cauldron lists only default-known, permanently unlocked, or currently required
  quest recipes. Before Sage's quest, only Calming Tea is listed.
- Keep the one-batch cap only while a recipe's quest is active/ready. Once Root-Wake
  Tonic is permanently unlocked after completion, normal batch limits apply.

### Quest rewards and UI

- Add optional `reward_recipes: [String]` to quest JSON and validate recipe IDs when
  quest data loads.
- Set Sage's reward to include `root_wake_tonic`; `QuestSystem.complete_quest()` unlocks
  recipe rewards after successfully consuming the turn-in item and granting existing
  rewards.
- Connect the HUD to `recipe_unlocked` and show `Recipe learned: Root-Wake Tonic`.
- Add `known_recipes` to save data and update the save version to `0.6.0`.
- For compatibility, loading a 0.5 save with Sage already completed must unlock every
  recipe listed in that quest's `reward_recipes` without replaying rewards or toasts.

## Implementation Order

1. Add `ShopState`, migrate display persistence, and verify old saves.
2. Add Marigold's room and move the bed.
3. Add/split the three shop doorways and transition spawn points.
4. Reposition counter-adjacent objects and rebuild visitor routes.
5. Add recipe knowledge state and save support.
6. Add quest recipe rewards, cauldron filtering, migration, and unlock toast.
7. Run the complete 0.6 acceptance test and update the handoff.

## Acceptance Test

1. Start a new game and confirm the shop has a forest door, customer/front door, and
   room door.
2. Use the forest and room doors in both directions; confirm correct spawn position,
   facing, wall collision, and no corner clipping.
3. Confirm the player cannot use the front door to enter an unbuilt exterior.
4. Confirm Sage and the generic customer enter from and leave through the front door.
5. Confirm the customer visits the front display, routes around the counter, and waits
   on its public side while Marigold can attend from behind it.
6. Confirm the cauldron is usable behind the counter and does not obstruct the customer
   route.
7. Stock Calming Tea, enter Marigold's room, sleep, quit, and Continue. Confirm the game
   loads in the room and the tea is still stocked when returning to the shop.
8. On a new game, confirm only Calming Tea is initially listed at the cauldron.
9. Accept Sage's quest and confirm Root-Wake Tonic appears temporarily.
10. Complete the quest and confirm the recipe-learned toast appears and Root-Wake Tonic
    remains craftable with normal batch limits.
11. Sleep, quit, and Continue; confirm the recipe remains known.
12. Load a 0.5 save with Sage completed and confirm Root-Wake Tonic is learned without
    duplicating gold, items, or quest dialogue.

## Non-Goals

- Front-of-shop exterior, village map, or visitor schedules.
- New room art, room decoration, storage, cooking, or wardrobe systems.
- Multiple displays, multiple customers, pricing, preferences, or navigation AI.
- Recipe book screen, recipe experimentation, item quality, or traits.
- New quest, NPC, ingredient, recipe, or region content.
