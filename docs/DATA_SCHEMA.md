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
data/quests.json
data/save_template.json
```

Later files:

```text
data/relationships.json
data/locations.json
data/calendar.json
data/seasons.json
data/festivals.json
data/item_traits.json
data/customer_types.json
data/shop_layouts.json
data/facilities.json
data/player_stats.json
data/companion_arcs.json
data/combat_rescue.json
data/outfits.json
```

Do not add the later files until a focused milestone actually needs them.

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
food
quest_item
tool
currency
weapon
seed
```

For the vertical slice, keep runtime inventory as item IDs and quantities. Later Atelier-style systems can add per-stack or per-instance item quality and traits. Do not add these fields until crafting needs them.

Possible later item instance shape:

```json
{
  "instance_id": "moonleaf_0001",
  "item_id": "moonleaf",
  "quantity": 3,
  "quality": 42,
  "traits": ["fragrant", "moon_touched"]
}
```

Possible later trait definition:

```json
{
  "id": "moon_touched",
  "name": "Moon-touched",
  "description": "Improves calming and sleep-related recipes.",
  "tags": ["calming", "night", "magic"]
}
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
kitchen
potting_bench
```

For vertical slice 0.6, `cauldron` is used for both Calming Tea and Root-Wake Tonic.

### Optional Fields

```text
quest_id
```

`quest_id` can temporarily expose a recipe while its quest is active or ready. In
vertical slice 0.6, `root_wake_tonic` uses `quest_id = "sage_first_request"`; completing
the quest adds it to saved recipe knowledge. Recipes with `known_by_default: true` are
always known and are not duplicated in `known_recipes` save data.

Later, separate crafting and cooking by station and output category:

* Crafting creates non-edible items, magical items, tools, charms, remedies, and shop goods.
* Cooking creates normal food.
* Both systems require known recipes and required ingredients.
* Cafe menus can only use food recipes the player has cooked before.

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
    "name": "Saffron",
    "role": "companion",
    "portrait": "res://art/characters/portraits/saffron.png",
    "sprite": "res://art/characters/saffron/Saffron.tres",
    "relationship": 0,
    "default_dialogue": "saffron_default",
    "likes": [],
    "dislikes": [],
    "shop_request_pool": [],
    "tags": ["companion", "mascot", "cat", "home_property"]
  }
]
```

Long-term Saffron rules:

* Saffron stays on Marigold's home property: shop, room, farm, and cafe.
* He may speak early in the game, then gradually transitions to normal cat meows.
* He should not follow Marigold into town, gathering maps, caves, ancient-region maps, or combat areas.
* His later arc can track meeting a white village cat and eventually having kittens.

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

## 8.1 Future Shop Session Data

The vertical slice uses one deterministic customer request. Later shop management should track display stock, price, customer type, preferences, and shop open/closed state.

Possible display listing:

```json
{
  "display_id": "front_table_left",
  "item_instance_id": "calming_tea_0004",
  "item_id": "calming_tea",
  "quantity": 1,
  "price": 18
}
```

Possible customer type:

```json
{
  "id": "tired_worker",
  "name": "Tired Worker",
  "preferred_tags": ["food", "calming", "stamina"],
  "disliked_tags": ["expensive", "dangerous"],
  "seasonal_interest": {
    "spring": ["plant", "tea"],
    "summer": ["cooling", "water"],
    "autumn": ["warm", "mushroom"],
    "winter": ["hearty", "fire"]
  }
}
```

Possible shop state:

```json
{
  "is_open": false,
  "displays": [],
  "active_customers": [],
  "price_presets": {
    "default_markup_percent": 20
  }
}
```

Quest NPCs should only visit while the shop is closed. Browsing customers should only enter while the shop is open.

The shop should remain optional income and village flavor. Do not make daily shop operation a required progression gate unless a specific quest asks for it.

## 8.2 Calendar and Season Data

The full game starts on `Spring 1`. One year has four months: `spring`, `summer`, `autumn`, and `winter`.

Possible calendar save data:

```json
{
  "year": 1,
  "season": "spring",
  "day": 1
}
```

Possible seasonal item popularity:

```json
{
  "item_id": "calming_tea",
  "season_popularity": {
    "spring": 1.0,
    "summer": 0.9,
    "autumn": 1.2,
    "winter": 1.3
  }
}
```

Possible seed availability:

```json
{
  "seed_item_id": "moonleaf_seed",
  "wild_seasons": ["spring", "autumn"],
  "plant_shop_available_all_year": true
}
```

## 8.3 Facilities, Cafe, and Player Stats

Facility unlocks can eventually track the shop, Marigold's room, kitchen extension, greenhouse, cafe, and village upgrades.

Possible facility record:

```json
{
  "id": "kitchen_extension",
  "name": "Kitchen Extension",
  "unlocked": false,
  "upgrade_level": 0
}
```

Possible cafe menu record:

```json
{
  "recipe_id": "berry_toast",
  "has_cooked_before": true,
  "can_serve_at_cafe": true
}
```

Possible player stats:

```json
{
  "hp": 40,
  "max_hp": 40,
  "stamina": 60,
  "max_stamina": 60,
  "combat_level": 1,
  "equipped_weapon_id": "training_staff"
}
```

Stamina should decrease when the player performs tool actions, including farming tools and magic staff attacks. HP should decrease when monsters touch or damage Marigold.

Possible combat rescue state:

```json
{
  "doctor_npc_id": "doctor",
  "gold_loss_percent": 10,
  "wake_time_block": "late_morning",
  "wake_location": "home_room",
  "dialogue_id": "doctor_after_rescue"
}
```

When Marigold loses all HP, she should wake at home the next day with the doctor nearby, lose a small amount of money, and start later than usual.

## 8.4 Quest and Progression Data

The current 0.6 quest data is intentionally small and authored. It supports a specific
crafted-item turn-in, item/gold/recipe rewards, saved completion state, and migration of
recipe rewards for older completed saves.

Current quest record:

```json
{
  "id": "sage_first_request",
  "title": "A Little Root Trouble",
  "npc_name": "Sage",
  "turn_in_item_id": "root_wake_tonic",
  "turn_in_quantity": 1,
  "reward_gold": 25,
  "reward_items": {
    "moonleaf_seed_packet": 1
  },
  "reward_recipes": ["root_wake_tonic"],
  "start_lines": [],
  "reminder_lines": [],
  "complete_lines": []
}
```

`reward_recipes` is optional. Each referenced ID must exist in `data/recipes.json`.
`QuestSystem.complete_quest()` unlocks those recipes only after the turn-in item is
successfully consumed and the other rewards are granted.

Vertical Slice 0.7 plans two small optional availability fields:

```json
{
  "required_quests": ["sage_first_request"],
  "minimum_day": 2
}
```

These fields should remain simple prerequisite checks, not a generic condition system.

Quest save data is a dictionary keyed by quest ID:

```json
{
  "quests": {
    "sage_first_request": "completed"
  }
}
```

Allowed current quest states:

```text
not_started
active
ready_to_turn_in
completed
```

Quest chains should be the main unlock structure for the full game. Craft milestones, reputation, and money can support progression, but quests should be the clearest source of new areas, recipes, facilities, village upgrades, and larger systems.

Possible quest record:

```json
{
  "id": "restore_forest_path",
  "name": "Restore the Forest Path",
  "giver_npc_id": "camellia",
  "objectives": [
    {
      "type": "deliver_item",
      "item_id": "calming_tea",
      "quantity": 1
    }
  ],
  "unlocks": {
    "locations": ["deeper_forest"],
    "recipes": ["embercap_tonic"],
    "facilities": []
  }
}
```

Possible companion arc record:

```json
{
  "id": "saffron_home_arc",
  "companion_id": "cat",
  "stage": "speaks",
  "allowed_location_tags": ["home_property"],
  "flags": {
    "met_white_cat": false,
    "has_kittens": false
  }
}
```

Possible location unlock record:

```json
{
  "id": "deeper_forest",
  "name": "Deeper Forest",
  "region_type": "gathering",
  "unlocked": false,
  "unlock_quest_id": "restore_forest_path"
}
```

## 8.5 Future Outfit Data

Marigold should eventually be able to change outfits. Do not add outfit systems until a focused milestone needs character customization, seasonal clothing, festival outfits, or region-specific clothes.

Possible outfit record:

```json
{
  "id": "default_autumn_witch",
  "name": "Autumn Witch Dress",
  "description": "Marigold's default moss-green dress, rust shawl, olive hat, and brown boots.",
  "sprite_frames": "res://art/characters/marigold/outfits/default_autumn_witch.tres",
  "portrait": "res://art/characters/portraits/marigold_default_autumn_witch.png",
  "unlocked_by_default": true,
  "tags": ["default", "autumn", "witch", "shop", "gathering"]
}
```

Outfit rules:

* The default outfit is the recognizable autumn witch design.
* Alternate outfits can support seasons, festivals, shop work, gathering, cafe work, romance events, or regional styles.
* Alternate outfits should preserve Marigold's readable silhouette and warm handcrafted witch identity.

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

Current vertical-slice save file:

```json
{
  "version": "0.6.0",
  "day": 2,
  "inventory": {
    "moonleaf": 2,
    "forest_water": 1,
    "calming_tea": 0,
    "root_wake_tonic": 0
  },
  "gold": 43,
  "gatherables_depleted": {
    "moonleaf_bush_001": true
  },
  "quests": {
    "sage_first_request": "completed"
  },
  "known_recipes": ["root_wake_tonic"],
  "shop_displays": {
    "main_display": {
      "item_id": "calming_tea",
      "quantity": 1
    }
  },
  "current_scene": "res://scenes/world/MarigoldRoom.tscn",
  "player_position": {
    "x": 120,
    "y": 180
  }
}
```

`shop_displays` stores stable stock only. Customer reservation, movement, open-shop
session state, and UI state are transient. Default-known recipes are derived from
recipe data; `known_recipes` stores only permanent progression unlocks.

Possible long-term save fields include time blocks, flags, relationships, and richer
gatherable records. These are not part of save version 0.6.0:

```json
{
  "version": "future",
  "day": 1,
  "time_block": "morning",
  "inventory": {
    "moonleaf": 0,
    "forest_water": 0,
    "calming_tea": 0
  },
  "gold": 0,
  "current_scene": "res://scenes/world/ShopInterior.tscn",
  "player_position": {
    "x": 480,
    "y": 440
  },
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
* Every quest turn-in and reward item exists.
* Every quest recipe reward exists.
* Every quest prerequisite exists and is not the quest itself.
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
