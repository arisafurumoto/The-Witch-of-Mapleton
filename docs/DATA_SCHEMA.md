# DATA_SCHEMA.md

# The Witch of Mapleton - Data Schema

## 1. Data Philosophy

The game should be data-driven wherever practical.

Core content should live in JSON files so that items, recipes, NPCs, dialogue, shop requests, and quest flags can be edited without rewriting gameplay code.

The first version should stay simple. Avoid advanced abstractions until the basic loop is playable.

Priority:

```text
Readable data
Simple structure
Easy AI editing
Easy validation
Easy save/load
```

Avoid:

```text
Overly nested data
Premature rarity systems
Complex item modifiers
Large content sets before systems work
Hard-coded dialogue
Hard-coded recipes
Hard-coded NPC preferences
```

## 2. File Locations

Recommended files:

```text
data/items.json
data/recipes.json
data/npcs.json
data/dialogue/camellia.json
data/dialogue/customer_generic.json
data/dialogue/cat.json
data/shop_requests.json
data/save_template.json
```

Later files:

```text
data/quests.json
data/relationships.json
data/locations.json
data/calendar.json
data/seasons.json
data/festivals.json
```

Do not add the later files until the vertical slice works.

## 3. Item Schema

Items represent ingredients, crafted goods, quest items, tools, and currency-like objects.

### Item Fields

```json
{
  "id": "moonleaf",
  "name": "Moonleaf",
  "category": "ingredient",
  "description": "A soft silver-green leaf that curls toward moonlight.",
  "stack_limit": 99,
  "sell_price": 4,
  "icon": "res://art/items/moonleaf.png",
  "tags": ["plant", "forest", "moon"]
}
```

### Required Fields

```text
id
name
category
description
stack_limit
sell_price
icon
tags
```

### Allowed Categories

```text
ingredient
crafted_good
quest_item
tool
currency
```

### Initial Items

```json
[
  {
    "id": "moonleaf",
    "name": "Moonleaf",
    "category": "ingredient",
    "description": "A soft silver-green leaf that curls toward moonlight.",
    "stack_limit": 99,
    "sell_price": 4,
    "icon": "res://art/items/moonleaf.png",
    "tags": ["plant", "forest", "moon"]
  },
  {
    "id": "forest_water",
    "name": "Forest Water",
    "category": "ingredient",
    "description": "Clear spring water gathered from a shaded forest pool.",
    "stack_limit": 99,
    "sell_price": 2,
    "icon": "res://art/items/forest_water.png",
    "tags": ["water", "forest", "spring"]
  },
  {
    "id": "calming_tea",
    "name": "Calming Tea",
    "category": "crafted_good",
    "description": "A gentle herbal tea that settles nerves and softens the edge of a difficult day.",
    "stack_limit": 99,
    "sell_price": 18,
    "icon": "res://art/items/calming_tea.png",
    "tags": ["tea", "crafted", "calming"]
  }
]
```

## 4. Recipe Schema

Recipes define crafting inputs and outputs.

### Recipe Fields

```json
{
  "id": "calming_tea",
  "name": "Calming Tea",
  "station": "cauldron",
  "ingredients": {
    "moonleaf": 2,
    "forest_water": 1
  },
  "output": {
    "item_id": "calming_tea",
    "quantity": 1
  },
  "craft_time": 1,
  "known_by_default": true
}
```

### Required Fields

```text
id
name
station
ingredients
output
craft_time
known_by_default
```

### Allowed Stations

```text
cauldron
workbench
drying_rack
stove
mortar
```

For vertical slice 0.1, only `cauldron` is needed.

### Initial Recipes

```json
[
  {
    "id": "calming_tea",
    "name": "Calming Tea",
    "station": "cauldron",
    "ingredients": {
      "moonleaf": 2,
      "forest_water": 1
    },
    "output": {
      "item_id": "calming_tea",
      "quantity": 1
    },
    "craft_time": 1,
    "known_by_default": true
  }
]
```

## 5. Inventory Save Schema

The runtime inventory can be a dictionary keyed by item ID.

```json
{
  "moonleaf": 3,
  "forest_water": 1,
  "calming_tea": 0
}
```

Rules:

* Do not store item names in the save file.
* Store only item IDs and quantities.
* Load item display data from `items.json`.
* Quantity must never be negative.
* Unknown item IDs should log a warning.

## 6. NPC Schema

NPCs define identity, role, relationship data, likes, dislikes, and dialogue references.

### NPC Fields

```json
{
  "id": "camellia",
  "name": "Camellia",
  "role": "restaurant_owner",
  "portrait": "res://art/characters/portraits/camellia.png",
  "sprite": "res://art/characters/npcs/camellia.png",
  "relationship": 0,
  "default_dialogue": "camellia_first_meeting",
  "likes": ["calming_tea"],
  "dislikes": [],
  "shop_request_pool": ["calming_tea"],
  "tags": ["romance_candidate", "village", "food"]
}
```

### Required Fields

```text
id
name
role
portrait
sprite
relationship
default_dialogue
likes
dislikes
shop_request_pool
tags
```

### Initial NPCs

```json
[
  {
    "id": "camellia",
    "name": "Camellia",
    "role": "restaurant_owner",
    "portrait": "res://art/characters/portraits/camellia.png",
    "sprite": "res://art/characters/npcs/camellia.png",
    "relationship": 0,
    "default_dialogue": "camellia_first_meeting",
    "likes": ["calming_tea"],
    "dislikes": [],
    "shop_request_pool": ["calming_tea"],
    "tags": ["romance_candidate", "village", "food"]
  },
  {
    "id": "generic_customer",
    "name": "Villager",
    "role": "customer",
    "portrait": "res://art/characters/portraits/generic_customer.png",
    "sprite": "res://art/characters/npcs/generic_customer.png",
    "relationship": 0,
    "default_dialogue": "customer_first_sale",
    "likes": ["calming_tea"],
    "dislikes": [],
    "shop_request_pool": ["calming_tea"],
    "tags": ["customer"]
  },
  {
    "id": "cat",
    "name": "Cat",
    "role": "companion",
    "portrait": "res://art/characters/portraits/cat.png",
    "sprite": "res://art/characters/companions/black_cat.png",
    "relationship": 0,
    "default_dialogue": "cat_default",
    "likes": [],
    "dislikes": [],
    "shop_request_pool": [],
    "tags": ["companion", "mascot", "cat"]
  }
]
```

## 7. Dialogue Schema

Dialogue should be simple first.

### Simple Dialogue File

```json
{
  "id": "camellia_first_meeting",
  "speaker": "Camellia",
  "lines": [
    "You must be the new witch.",
    "Mapleton has been waiting for one of those.",
    "I mean that kindly. Mostly."
  ]
}
```

### Dialogue With Conditions

Use this later, not for the first implementation.

```json
{
  "id": "camellia_after_first_sale",
  "speaker": "Camellia",
  "conditions": {
    "flags_required": ["first_sale_complete"]
  },
  "lines": [
    "That tea helped more than I expected.",
    "You may actually know what you are doing."
  ]
}
```

### Dialogue Rules

* Dialogue ID must be unique.
* Dialogue should not be hard-coded in scenes.
* Each NPC points to a default dialogue ID.
* Branching dialogue can come later.
* Conditions should be added only after the basic dialogue box works.

## 8. Shop Request Schema

Shop requests define what a customer wants to buy.

```json
{
  "id": "first_calming_tea_request",
  "customer_id": "generic_customer",
  "requested_item_id": "calming_tea",
  "quantity": 1,
  "offered_gold": 18,
  "dialogue_start": "customer_requests_calming_tea",
  "dialogue_success": "customer_receives_calming_tea",
  "dialogue_failure": "customer_no_item"
}
```

Initial shop requests:

```json
[
  {
    "id": "first_calming_tea_request",
    "customer_id": "generic_customer",
    "requested_item_id": "calming_tea",
    "quantity": 1,
    "offered_gold": 18,
    "dialogue_start": "customer_requests_calming_tea",
    "dialogue_success": "customer_receives_calming_tea",
    "dialogue_failure": "customer_no_item"
  }
]
```

## 9. Gatherable Node Schema

Gatherable nodes can be configured in scenes or data. For the vertical slice, scene-exported variables are acceptable.

Recommended fields:

```json
{
  "id": "moonleaf_bush_001",
  "display_name": "Moonleaf Bush",
  "item_id": "moonleaf",
  "quantity": 2,
  "reset_daily": true,
  "requires_tool": null,
  "depleted": false
}
```

Rules:

* Each gatherable in the world needs a unique ID.
* Save file stores depleted state by ID.
* Daily reset restores nodes where `reset_daily` is true.
* Do not add random drop tables until the basic gather system works.

## 10. Save Game Schema

Initial save file:

```json
{
  "version": "0.1.0",
  "day": 1,
  "time_block": "morning",
  "player": {
    "scene": "res://scenes/world/shop_interior.tscn",
    "position": {
      "x": 160,
      "y": 120
    }
  },
  "inventory": {
    "moonleaf": 0,
    "forest_water": 0,
    "calming_tea": 0
  },
  "gold": 0,
  "flags": [],
  "relationships": {
    "camellia": 0,
    "generic_customer": 0,
    "cat": 0
  },
  "gatherables": {
    "moonleaf_bush_001": {
      "depleted": false
    },
    "forest_water_spring_001": {
      "depleted": false
    }
  }
}
```

## 11. Save Rules

* Include a save version.
* Do not save derived display data.
* Save only stable IDs and state.
* Never save temporary UI state.
* Save after sleeping.
* Later, allow manual save if desired.
* When loading unknown fields, ignore them.
* When required fields are missing, use safe defaults.

## 12. Flags

Flags are simple strings used for progression.

Initial flags:

```text
first_moonleaf_gathered
first_forest_water_gathered
first_craft_complete
first_sale_complete
first_sleep_complete
```

Example:

```json
{
  "flags": [
    "first_moonleaf_gathered",
    "first_craft_complete"
  ]
}
```

## 13. Relationship Data

For vertical slice 0.1, relationships can exist in save data but do not need gameplay depth.

```json
{
  "relationships": {
    "camellia": 0,
    "generic_customer": 0,
    "cat": 0
  }
}
```

Later, this can expand into:

```json
{
  "camellia": {
    "points": 120,
    "level": 1,
    "seen_events": [],
    "gifted_today": false,
    "talked_today": true
  }
}
```

Do not implement the expanded version yet.

## 14. Validation Rules

Claude Code should add simple validation when loading data.

Check:

* Every item has a unique ID.
* Every recipe output item exists.
* Every recipe ingredient exists.
* Every NPC default dialogue ID exists.
* Every shop request item exists.
* Every shop request customer exists.
* Stack limits are greater than 0.
* Sell prices are 0 or higher.
* Quantities are greater than 0.

Errors should be logged clearly.

## 15. Initial Implementation Order

Data systems should be implemented in this order:

1. Item database loader
2. Inventory runtime dictionary
3. Recipe database loader
4. Crafting validator
5. NPC database loader
6. Dialogue loader
7. Shop request loader
8. Save/load system

Do not implement all loaders at once. Add them as each gameplay system requires them.
