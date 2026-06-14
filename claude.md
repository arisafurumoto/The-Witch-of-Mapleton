# The Witch of Mapleton - Claude Code Instructions

This is a Godot 4 GDScript project.

The game is a cosy top-down 3/4 pixel-art witch life sim about **Marigold**, a young witch with wavy purple shoulder-length hair, who runs a magical shop in the village of Mapleton with her black cat companion.

## Project Goal

Build the first playable vertical slice before expanding the game.

The first vertical slice is called:

**First Potion Sale**

Required player flow:

1. Start inside Marigold's witch shop.
2. Move around.
3. Black cat follows the player.
4. Exit to a small forest clearing.
5. Gather Moonleaf and Forest Water.
6. Return to the shop.
7. Craft Calming Tea.
8. A customer enters the shop.
9. Customer asks for Calming Tea.
10. Player sells Calming Tea.
11. Player receives gold.
12. Player sleeps.
13. Game saves.
14. New day begins.

Do not build beyond this target unless explicitly asked.

## Development Rules

* Build one system at a time.
* Keep code simple, readable, and beginner-friendly.
* Prefer GDScript.
* Prefer data-driven systems using JSON.
* Do not add features that were not requested.
* Do not implement future systems early.
* Do not do large rewrites unless specifically asked.
* Avoid clever abstractions.
* Avoid premature architecture.
* Use placeholder art until the gameplay loop works.
* After each change, list changed files.
* Explain how to test changes in Godot.
* If there is a bug, fix the smallest likely cause first.
* If a system can be implemented in a simple way or a flexible way, choose the simple way first.

## Visual Direction

The game uses modern top-down 3/4 pixel art inspired by Chef RPG.

It is not isometric. It uses conventional 2D movement and collision, but objects are drawn with visible front faces and vertical depth.

The art direction is:

* Cosy
* Witchy
* Warm
* Magical
* Dense
* Handcrafted
* Autumnal
* Lantern-lit
* Atmospheric
* Readable at small pixel scale

PixelLab is used for production-oriented pixel asset drafts.

Aseprite or Pixelorama is used for cleanup.

Godot is used to test all assets at real game scale.

## Technical Direction

Use:

* Godot 4
* GDScript
* 2D scenes
* Forward+ renderer
* 640×360 internal resolution
* Pixel-perfect scaling
* 16×16 base tiles
* 32×48 character sprites
* 128×128 dialogue portraits

Use a layered 2D scene structure:

```text
Ground TileMapLayer
Path TileMapLayer
Low Detail TileMapLayer
Collision TileMapLayer
Y-sorted characters and props
Foreground overlays
CanvasModulate global tint
2D lights
Particles
UI CanvasLayer
```

## Data-Driven Design

Use JSON data files for core content.

Expected data files:

```text
data/items.json
data/recipes.json
data/npcs.json
data/shop_requests.json
data/dialogue/
```

Do not hard-code item names, recipe ingredients, NPC dialogue, or shop requests unless explicitly temporary.

Use stable IDs.

Examples:

```text
moonleaf
forest_water
calming_tea
camellia
generic_customer
cat
first_calming_tea_request
```

## Current Core Items

Initial items:

* Moonleaf
* Forest Water
* Calming Tea

Initial recipe:

**Calming Tea**

Requires:

* Moonleaf × 2
* Forest Water × 1

Produces:

* Calming Tea × 1

## Initial NPCs

Only implement these at first:

* Marigold, the player character
* Black cat companion
* Generic customer
* Camellia, restaurant owner, only if needed for dialogue testing

Do not add romance systems yet.

Do not add the full village cast yet.

## Initial Systems Order

Implement systems in this order:

1. Player movement
2. Camera follow
3. Collision
4. Interaction system
5. Scene transition between shop and forest
6. Item database loader
7. Inventory system
8. Gatherable nodes
9. Crafting system
10. Shop sale system
11. Dialogue box
12. Black cat companion follow
13. Save/load
14. Day advancement

Do not skip ahead unless explicitly requested.

## Coding Style

Use clear file and node names.

Prefer names like:

```text
PlayerController.gd
Inventory.gd
ItemDatabase.gd
RecipeDatabase.gd
CraftingSystem.gd
ShopSystem.gd
DialogueBox.gd
CatCompanion.gd
SaveSystem.gd
DaySystem.gd
```

Use signals for simple communication where appropriate.

Good examples:

```gdscript
signal inventory_changed
signal item_gathered(item_id: String, quantity: int)
signal crafting_completed(item_id: String, quantity: int)
signal dialogue_finished
```

Avoid excessive inheritance.

Avoid building a generic framework before the specific game loop works.

## Scene Structure Preference

Prefer small focused scenes.

Examples:

```text
scenes/player/Player.tscn
scenes/world/ShopInterior.tscn
scenes/world/ForestClearing.tscn
scenes/ui/DialogueBox.tscn
scenes/ui/InventoryPanel.tscn
scenes/systems/GameManager.tscn
scenes/npc/GenericCustomer.tscn
scenes/npc/CatCompanion.tscn
```

## Placeholder Art Rule

Use placeholder art first.

Acceptable placeholders:

* Coloured rectangles
* Simple circles
* Temporary sprites
* Labelled debug objects

Do not spend development time on polished art before the loop is playable.

Final art will come from:

```text
PixelLab → Aseprite or Pixelorama → Godot
```

## Testing Rule

After implementing a feature, explain how to test it manually.

Example format:

```text
To test:
1. Open scenes/world/ShopInterior.tscn.
2. Press Play.
3. Move with WASD or arrow keys.
4. Walk to the door.
5. Press interact.
6. Confirm the player changes scene.
```

## Response Format

After each implementation, respond with:

```text
Changed files:
- path/to/file.gd
- path/to/file.tscn

What changed:
- Short summary of behaviour.

How to test:
- Step-by-step manual test.

Notes:
- Anything that is incomplete, temporary, or needs review.
```

## Non-Goals For Now

Do not implement:

* Romance
* Festivals
* Seasons
* Ancient region
* Full town map
* Farming
* Fishing
* Combat
* Complex economy
* Dozens of NPCs
* Large quest chains
* Procedural generation
* Advanced lighting system
* Complex shader pipeline
* Full decoration system
* Multiple endings

## Main Risk

The main risk is uncontrolled scope.

The correct strategy is:

**Make one beautiful, tiny, working loop first.**

Do not expand the project until the First Potion Sale vertical slice works end-to-end.
