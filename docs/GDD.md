# The Witch of Mapleton - Phase 1 Production Brief

## 1. Game Summary

**The Witch of Mapleton** is a cosy 2D pixel-art life sim about a young witch named **Marigold** who moves to the overgrown village of Mapleton and opens a small magical shop. With the help of her black cat companion, she gathers ingredients, crafts potions and charms, fulfills requests, serves villagers, builds relationships, uncovers local mysteries, and gradually restores magic to the village.

The game should feel warm, magical, intimate, and gently mysterious. The player fantasy is not “become powerful and defeat evil.” The fantasy is “build a meaningful magical life, become part of a village, and make small beautiful things that help people.”

The long-term design direction is **Atelier series meets cosy life sim**. The main progression should lean more Atelier than farm sim: gather ingredients, craft useful or magical items, complete quests, unlock new maps, learn recipes, discover better materials, and improve the village, shop, cafe, or other facilities over time.

## 2. Core Player Fantasy

The player is a small-town witch running a magical shop.

The player should feel:

* Cosy and safe
* Clever and resourceful
* Needed by the village
* Surrounded by nature and magic
* Emotionally attached to NPCs and the black cat
* Curious about the deeper magical history of the region

The strongest reference feeling is:

> Atelier-style gathering, alchemy, item quality, and quest progression inside a cosy witch life sim, with shop management as an optional but meaningful way to earn money and connect with Mapleton.

## 3. Game Pillars

### Pillar 1: Cosy Witch Life

The game is about daily rituals: waking up, checking the shop, gathering ingredients, crafting, talking to villagers, selling magical goods, and ending the day.

The player should always have small meaningful tasks to do, but the game should not feel stressful.

### Pillar 2: Shopkeeping With Personality

The shop is the emotional and mechanical centre of the game. The player crafts potions, teas, charms, remedies, and magical objects, then sells them to villagers.

Customers should feel like people, not vending-machine transactions. They have preferences, problems, moods, and relationship history.

Opening the shop should be a choice, not a daily obligation. The player can stock displays, set prices, open the shop, and let customers browse. Shop management should be closer to Moonlighter than a manual serving game: customers enter, inspect items, decide whether to buy or leave, then bring chosen items to the counter for Marigold to complete the sale.

### Pillar 3: Nature, Magic, and Gathering

The surrounding forest, village edges, river, garden, and later ancient region provide ingredients. Gathering should feel calm and sensory, not grindy.

Ingredients should feel magical and specific:

* Moonleaf
* Embercap mushroom
* Dewberries
* Star-moss
* River glass
* Foxglove ash
* Lantern pollen

### Pillar 4: Relationships and Village Life

NPCs are central. The player should build friendships, romance candidates, and regular customer relationships.

The world should feel inhabited. NPCs have routines, preferences, dialogue changes, seasonal comments, and personal quests.

### Pillar 5: Hidden History

The game starts as a cosy village shop game, then gradually reveals a deeper magical history. The ancient region unlocks mid-game and introduces new ingredients, characters, architecture, spirits, rituals, and lore.

This deeper mystery should enrich the cosy loop, not replace it.

## 4. Target Style

### Visual Style

Pixel art, non-isometric, top-down or slightly top-down 2D.

Recommended production specs:

* Tile size: 16×16 px
* Character sprite: 32×48 px
* Dialogue portraits: 96×96 px
* UI icons: 16×16 px
* Larger item icons: 32×32 px
* Display scale: 3× or 4×

### Colour Direction

The game should use:

* Purple hues
* Warm sunset tones
* Autumn oranges and browns
* Soft mist
* Lantern glow
* Dark timber
* Overgrown greenery
* Muted magical highlights

The world should not look neon, harsh, cyber, or overly saturated.

### Main Character

Name: **Marigold**

Description:

* Young witch
* Wavy purple shoulder-length hair
* Dark, simple outfit
* Practical rather than flashy
* Soft gothic/cottage witch feel
* Expressive but not overly cute
* Should read clearly at small pixel scale

### Mascot

Black cat companion.

Role:

* Follows the player
* Reacts to events
* Gives small comments
* Adds humour and emotional warmth
* May later help find magical traces or hidden ingredients

The cat should not be a tutorial machine. It should feel like a companion.

## 5. Core Gameplay Loop

The main loop:

1. Wake up in Marigold's room.
2. Check tasks, inventory, and requests.
3. Gather ingredients from nearby areas.
4. Craft magical goods, tools, quest items, or stock for the shop.
5. Optionally open the shop by stocking displays and setting prices.
6. Serve customers at the counter if they choose to buy.
7. Talk to villagers and accept quests.
8. Unlock or upgrade maps, recipes, tools, village facilities, shop features, or cafe systems.
9. Return to Marigold's room, sleep to save, and start the next day.

The loop should be short enough that one day can be played in 10 to 15 minutes.

## 5.1 Long-Term Gameplay Direction

These systems describe the intended full game direction. They are not requirements for Vertical Slice 0.1 and should be implemented only when the current milestone calls for them.

### Gathering, Crafting, and Quests

The main gameplay is gathering ingredients, crafting items, and completing quests. Quests should push progression by unlocking new maps, recipes, items, facilities, village upgrades, or shop/cafe features.

The inventory should eventually feel large like an Atelier game. Items can have quality and traits, and those properties can affect the final crafted product. The first implementation can use plain item IDs and quantities; item quality and traits should come later when the basic crafting loop needs depth.

### Shop Management

Marigold owns a shop, but the player does not need to open it every day. The shop loop is:

1. Place sellable items on displays around the shop.
2. Set item prices with an easy bulk or guided pricing tool so pricing many items does not become busywork.
3. Open the shop.
4. Customers enter, browse displays, choose an item, or leave without buying.
5. Buying customers bring the item to the counter.
6. Marigold confirms payment and earns gold.

Customers should have types and item preferences. Season, item type, quality, traits, price, reputation, and customer preference can eventually affect purchase chance and satisfaction.

Quest NPCs can visit the shop while it is closed, but not while the shop is open. A quest visit should feel like someone coming to Marigold for help, not like a normal browsing customer.

### Calendar and Seasons

The game uses a calendar system like Harvest Moon. The game starts on **Spring 1**. One year has four months:

* Spring
* Summer
* Autumn
* Winter

Season should affect gathering, wild seeds, plant availability, customer demand, and item popularity. Some items should be more popular in specific seasons.

### Farming

Farming should be useful but intentionally limited so it does not become the main game. The farming area should be small, possibly a greenhouse or compact garden.

Seeds can be bought from a plant shop or gathered in the wild. Wild plants and wild seeds are seasonal. The plant shop can sell every seed type all year so the player is not locked out of important progression by the calendar.

### Shop, Room, Cooking, and Cafe

Marigold's shop and room are separate scenes.

The shop is where Marigold crafts, sells items, talks to customers, and receives shop-related visits. Marigold's room is in the back and is where she sleeps. With a kitchen extension, her room also becomes where she cooks.

Crafting and cooking are separate systems:

* Crafting creates non-edible items, magical items, tools, remedies, charms, and shop goods.
* Cooking creates normal food.
* Both systems require known recipes and required ingredients.

Once the cafe is unlocked, only recipes Marigold has cooked before can be served there. Marigold can also eat at her own cafe and be served like a customer. Food eaten at the cafe restores HP and stamina just like food eaten from inventory.

### Combat, HP, and Stamina

Combat should stay simple and supportive, closer to Stardew Valley than an action RPG. Marigold attacks monsters directly; if a monster touches her, she takes damage. Different weapons can make her stronger.

Marigold has HP, stamina, and a combat level. Stamina decreases when she performs tool actions, from using a watering can to swinging a magic staff. Combat and monster drops should support gathering and crafting rather than becoming the main focus.

## 6. First Playable Vertical Slice

The first milestone is called:

# Vertical Slice 0.1 - First Potion Sale

This is the smallest version of the game that proves the core concept.

### Required Player Flow

1. Player starts inside Marigold’s witch shop.
2. Player can move around.
3. Black cat follows the player.
4. Player exits the shop into a small forest clearing.
5. Player gathers Moonleaf and Forest Water.
6. Player returns to the shop.
7. Player uses a crafting station.
8. Player crafts Calming Tea.
9. A customer enters the shop.
10. Customer asks for Calming Tea.
11. Player sells Calming Tea.
12. Player receives gold.
13. Player sleeps.
14. Game saves.
15. New day begins.

### Success Criteria

The vertical slice is successful when:

* The player can complete the full loop without developer intervention.
* Inventory persists after saving.
* Gold persists after saving.
* Gatherable nodes reset on the next day.
* The shop sale works.
* The experience feels recognisably like the intended game, even with placeholder art.

### Explicitly Not Included In Vertical Slice 0.1

Do not include:

* Romance
* Festivals
* Seasons
* Full town map
* Full economy
* Multiple shop upgrades
* Ancient region
* Farming
* Combat
* Fishing
* Dozens of NPCs
* Large quest chains
* Complex cooking
* Animal care
* Multiplayer
* Procedural generation

## 7. MVP Feature Set

The MVP is larger than the first vertical slice, but still small.

### MVP Systems

Required:

* Player movement
* Camera follow
* Collision
* Interaction system
* Inventory
* Item database
* Gathering system
* Crafting system
* Shop selling system
* Basic customer requests
* Dialogue box
* Simple NPC system
* Black cat companion
* Save/load
* Day cycle
* Basic UI
* Basic audio
* Exportable build

Not required for MVP:

* Romance
* Full seasons
* Full festivals
* Large world map
* Advanced AI schedules
* Complex decoration system
* Full quest journal
* Deep relationship system
* Ancient region
* Multiple endings

## 8. Initial Systems List

### 8.1 Player Controller

Needs:

* 4-direction movement
* Idle state
* Walk state
* Interaction button
* Collision
* Camera follow

Animation can be placeholder at first.

### 8.2 Interaction System

Every interactable object should use the same basic interaction pattern.

Interactable examples:

* Door
* Gatherable plant
* Crafting station
* Shop counter
* Bed
* NPC
* Cat

The player presses interact. The nearest valid interactable responds.

### 8.3 Inventory System

The inventory tracks item IDs and quantities.

Minimum functions:

* Add item
* Remove item
* Check item quantity
* Check recipe requirements
* Emit inventory changed signal

No item quality system in version 0.1.

### 8.4 Item Database

Items should be data-driven.

Initial item categories:

* Ingredient
* Crafted good
* Quest item
* Tool

Initial items:

* Moonleaf
* Forest Water
* Calming Tea
* Gold

### 8.5 Gathering System

Gatherable nodes exist in the world.

Initial gatherables:

* Moonleaf Bush
* Forest Water Spring

Gatherables need:

* Available state
* Depleted state
* Item reward
* Reset on next day

### 8.6 Crafting System

Crafting uses recipes.

Initial recipe:

Calming Tea:

* Moonleaf × 2
* Forest Water × 1
* Produces Calming Tea × 1

Crafting should validate ingredients, remove inputs, and add output.

### 8.7 Shop System

Initial shop interaction:

* Customer enters
* Customer requests one item
* Player sells the item
* Gold increases
* Customer leaves

The shop system should be simple and deterministic at first.

### 8.8 Dialogue System

Dialogue should be data-driven.

Initial needs:

* Dialogue box
* Speaker name
* Text line
* Advance button
* End dialogue
* Trigger dialogue from NPC/customer/cat

Branching dialogue can come later.

### 8.9 NPC System

Initial NPCs:

* One customer
* One villager
* Black cat companion

NPCs need:

* Name
* Portrait placeholder
* Dialogue ID
* Optional request item

Schedules can come later.

### 8.10 Save/Load System

Save data should include:

* Current day
* Player position
* Inventory
* Gold
* Completed flags
* Gatherable depletion states
* Relationship values, even if unused initially

### 8.11 Day Cycle

Initial day states:

* Morning
* Afternoon
* Evening
* Night

Sleeping advances the day.

Gatherables reset after sleeping.

## 9. Initial Data Schemas

### Item

```json
{
  "id": "moonleaf",
  "name": "Moonleaf",
  "category": "ingredient",
  "description": "A soft silver-green leaf that curls toward moonlight.",
  "stack_limit": 99,
  "sell_price": 4
}
```

### Recipe

```json
{
  "id": "calming_tea",
  "name": "Calming Tea",
  "ingredients": {
    "moonleaf": 2,
    "forest_water": 1
  },
  "output": {
    "item_id": "calming_tea",
    "quantity": 1
  },
  "craft_time": 1
}
```

### NPC

```json
{
  "id": "camellia",
  "name": "Camellia",
  "role": "restaurant_owner",
  "relationship": 0,
  "default_dialogue": "camellia_first_meeting",
  "likes": ["calming_tea"],
  "dislikes": []
}
```

### Dialogue

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

## 10. Initial NPC Direction

The world should eventually include romance candidates and village NPCs, but version 0.1 only needs a tiny sample.

### Known Romance Candidate Concepts

Female candidates with flower names:

* Female doctor
* Female restaurant owner
* Female mermaid
* Female blacksmith
* Female librarian
* Wicked Glinda-inspired clothes shop owner

Male candidates:

* Priest from Japanese-inspired region
* One male candidate from the ancient region

Ancient region candidates:

* One male romance candidate
* One female romance candidate
* They move to Mapleton through quests after the ancient region unlocks

### MVP NPCs

For MVP, include only:

* Camellia, restaurant owner
* One generic customer
* Black cat companion

## 11. Initial Art Asset List

### Required For Vertical Slice 0.1

Characters:

* Marigold idle placeholder
* Marigold walk placeholder
* Black cat idle placeholder
* Black cat follow placeholder
* Customer placeholder

Environment:

* Witch shop floor
* Witch shop wall
* Shop counter
* Crafting table
* Bed
* Door
* Forest grass tile
* Forest dirt path tile
* Tree or bush tile
* Moonleaf bush
* Forest water spring

UI:

* Dialogue box
* Inventory panel
* Item slot
* Crafting panel
* Sell confirmation panel
* Gold display
* Day display

Items:

* Moonleaf icon
* Forest Water icon
* Calming Tea icon

Optional polish:

* Lantern glow
* Sparkle effect
* Tiny magic puff
* Shop bell animation

## 12. Initial Audio Asset List

Required:

* Footstep
* UI select
* UI confirm
* Gather ingredient
* Craft success
* Shop bell
* Coin/gold sound
* Cat meow
* Sleep transition

Optional:

* Soft shop ambience
* Forest ambience
* Gentle loopable music

## 13. Initial Folder Structure

```text
witch-of-mapleton/
  docs/
    GDD.md
    STYLE_GUIDE.md
    AI_WORKFLOW.md
    DATA_SCHEMA.md
  data/
    items.json
    recipes.json
    npcs.json
    dialogue/
  scenes/
    player/
    world/
    shop/
    ui/
    npc/
    systems/
  scripts/
    core/
    systems/
    ui/
    npc/
  art/
    characters/
    tilesets/
    ui/
    items/
    concepts/
  audio/
    sfx/
    music/
```

## 14. Development Rules

Use these rules for AI-assisted development:

1. Build one system at a time.
2. Keep systems small.
3. Use placeholder art first.
4. Do not generate large content sets before the loop works.
5. Prefer data-driven design.
6. Avoid clever architecture.
7. Keep GDScript readable.
8. Test every system in-engine.
9. Save/load must be added early.
10. Do not add features just because they are easy for AI to generate.

## 15. Current Priority

Vertical Slice 0.1, **First Potion Sale**, is complete and playable. The current priority is to preserve that tiny working loop while planning future systems in small, focused milestones.

Do not expand directly into the full long-term feature set. Choose one next system or polish pass at a time, and keep each milestone testable inside the existing loop.

Near-term milestone candidates:

* Keep polishing the First Potion Sale slice.
* Add a small second recipe/request only when the first loop feels stable.
* Add data-driven NPC/dialogue loaders when more than one reusable NPC or dialogue is needed.
* Split Marigold's room from the shop when sleeping/cooking needs a dedicated scene.
* Add calendar seasons only when a seasonal item or gatherable needs them.
