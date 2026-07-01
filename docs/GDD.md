# The Witch of Mapleton - Phase 1 Production Brief

## Handoff Summary

Current implementation work should follow `docs/PROGRESS.md` and the active slice plan.
This document is the long-term design source: **Atelier-style gathering, crafting, and
quest unlocks inside a cosy witch life sim**. Shopkeeping, farming, relationships, cafe
systems, combat, seasons, Homunculi, and larger town progression are real future
directions, but they should stay out of implementation until a focused vertical slice
explicitly needs them.

For day-to-day coding, use this file only to check long-term intent or avoid building a
system in the wrong direction. The current near-term work is still the small authored
first-week loop around Marigold, Saffron, Sage, Camellia, the shop, Mapleton Lane, and
the forest spaces.

## 1. Game Summary

**The Witch of Mapleton** is a cosy 2D pixel-art life sim about a young witch named **Marigold** who moves to the overgrown village of Mapleton and opens a small magical shop. With the help of her black cat companion, she gathers ingredients, crafts potions and charms, fulfills requests, serves villagers, builds relationships, uncovers local mysteries, and gradually restores magic to the village.

The game should feel warm, magical, intimate, and gently mysterious. The player fantasy is not “become powerful and defeat evil.” The fantasy is “build a meaningful magical life, become part of a village, and make small beautiful things that help people.”

The long-term design direction is **Atelier series meets cosy life sim**. The main progression should lean more Atelier than farm sim: gather ingredients, craft useful or magical items, complete quests, unlock new maps, learn recipes, discover better materials, and improve the village, shop, cafe, or other facilities over time.

The main long-term spine is **crafting and quest unlocks**. Shopkeeping, farming, relationships, cafe management, combat, and Homunculi support that spine instead of replacing it.

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
* Humanoid runtime frames: separated PNG folders with eight directions, six walk frames per direction, and one idle frame per direction
* Dialogue portraits: 140×140 px
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
* Long wavy copper-orange hair with loose curls
* Soft golden-brown eyes and a gentle, friendly expression
* Autumn village-witch outfit built around moss green, rust orange, cream, warm brown, amber, and gold
* Wide-brimmed olive-green witch hat with autumn flowers, leaves, and natural details
* Moss-green layered dress with fitted bodice, lace-up front, full skirt, and subtle gold floral embroidery
* Cream blouse or underdress with soft puffed sleeves and ruffled cuffs
* Rust-orange patterned shawl or capelet with tasselled edges
* Brown belt, tied rust sash, sturdy brown lace-up ankle boots, and a twisted wooden staff with a warm amber crystal or lantern-like gem
* Practical and handcrafted rather than flashy
* Cosy autumn cottage-witch feel
* Expressive but not overly cute
* Should read clearly at small pixel scale

Future customization direction: Marigold should eventually be able to change outfits. Her default design should remain the recognizable autumn witch look, while alternate outfits can support seasons, festivals, shop work, gathering, cafe work, romance events, or regional styles.

### Mascot

Black cat companion: **Saffron**.

Visual direction:

* Small black cat with warm dark-brown highlights in the fur
* Large golden-amber eyes that read clearly at small scale
* Oversized triangular ears with warm brown inner ear colour
* Olive-green collar with a gold-framed amber crystal pendant
* Soft rounded face, neat little paws, and a curled expressive tail
* Magical but understated; cute and observant without looking like a cartoon mascot

Role:

* Stays on Marigold's home property: shop, room, farm, and cafe
* Speaks early in the game, then gradually stops speaking and communicates with meows
* Reacts to events at home
* Gives small comments while he is still speaking
* Adds humour and emotional warmth
* Eventually meets a white cat from the village and later has kittens

The cat should not be a tutorial machine. It should feel like a companion.

Long-term, Saffron should not follow Marigold into the town, forest, caves, ancient region, or combat areas. The current vertical slice has him follow Marigold as an early proof-of-companion behavior; future design should treat that as slice-specific or tutorial-era behavior, not the full-game rule.

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

Item quality and traits should have **readable depth**. They should matter for crafting results, sale value, customer requests, and special quest requirements, but should stay approachable enough that players do not need spreadsheets to make useful items.

Progression should primarily come from authored quest chains. Crafting milestones, reputation, and money can support unlocks, but the clearest gates for new maps, recipes, facilities, village improvements, and larger systems should be quests.

### Item Naming and Language Flavor

Some magical item names can use French words as flavour, inspired by how some Atelier
items use German names. Use this selectively for memorable magical tools, potions,
charms, materials, or devices rather than making every item French.

French display names should feel whimsical, elegant, and readable. The item description
should explain what the item does in plain English so the player is never confused by
the foreign-language flavour.

Stable data IDs should remain simple lowercase slugs, such as `nuage`, while the display
name can be the French word, such as **Nuage**.

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

The shop is optional income and village flavor in normal play. Players should be able to spend several days gathering, crafting, questing, or socializing without being punished for not opening the shop.

### Karazon and Business Culture

Karazon is a large online shopping corporation inspired by Amazon. It should feel like
a big external economic force rather than a normal Mapleton shop. It does not have a
physical storefront in town, which helps it contrast with Marigold's handmade witch
shop, Camellia's restaurant, Sage's plant stall, Anemone's pond-side shop, and Alder's
butcher work.

The CEO of Karazon is originally from Mapleton. This gives the corporation a personal
link to the village instead of making it feel like a random outside company. He is still
the current CEO when the game takes place. He is ambitious, money-loving, and genuinely
good at building a business.

Karazon can be used as a long-term story thread about efficiency, convenience,
ambition, labour, money, and what small local businesses mean in a cosy fantasy town. It
is not a magical-goods company and does not sell the same kind of handcrafted potions or
charms as Marigold. Its strength is convenience: next-day delivery, free shipping, broad
selection, and the ease of ordering without visiting a shop.

This makes Karazon a philosophical rival to Marigold rather than a direct product copy.
Some villagers love using it because it is convenient and reliable. What Karazon lacks
is the human touch, local memory, face-to-face care, and sense of community that
Marigold pours into her crafts.

Long-term arc idea: once the CEO hears about Marigold's successful handmade witch
business, he visits or contacts her and offers to put her goods on Karazon. He proposes
mass-producing them, giving her a percentage, and making her a millionaire. Marigold
refuses because the thing she values is not money or scale; it is the care, love, and
personal intention she puts into each craft.

Linden works for Karazon remotely from Mapleton. His corporate routine, burnout, and
business analysis role make him a natural character lens for Karazon's values. Linden
does not see Karazon as simply evil or good. It is popular, convenient, and successful.
At the same time, he likes the small, quaint town he lives in and loves Marigold's
handcrafted work.

Anemone once met the future Karazon CEO when he was young, before he started Karazon. He
taught her about capitalism, money, and running a business. Because mermaid society is
based on trade and does not use money in the same way, Anemone became fascinated by
human society and eventually started her own shop. This should be playful and
character-driven, not a heavy economics lecture.

### Calendar and Seasons

The game uses a calendar system like Harvest Moon. The game starts on **Spring 1**. One year has four months:

* Spring
* Summer
* Autumn
* Winter

Season should affect gathering, wild seeds, plant availability, customer demand, and item popularity. Some items should be more popular in specific seasons.

### Weather

The weather system should stay simple. The only normal weather states are:

* Sunny
* Rainy

Rainy days should be much less common than sunny days. In winter, rainy weather appears
as snow instead of rain. This is still the same simple watering/weather category for
gameplay purposes, just with winter visuals and flavour.

Do not add storms, cloudy days, extreme weather, or complex forecasts unless a much
later milestone truly needs them.

Rainy and snowy days matter mainly for farming and atmosphere. When it rains, outside
farm plants are automatically watered for that day. In winter, snow waters outside
winter crops the same way. Greenhouse plants do not receive this weather watering
benefit because the greenhouse is sheltered.

Marigold should eventually be able to check the weather forecast on the radio. The
forecast can support simple planning without turning weather into a complex simulation.

### Farming

Farming should be useful but intentionally limited so it does not become the main game.
Marigold's property should eventually have enough space for several home facilities,
such as a buildable garden, animal farm, greenhouse, and monster farm. These should
unlock gradually so the property grows with her life in Mapleton.

Seeds can be bought from a plant shop or gathered in the wild. Wild plants and wild seeds are seasonal. The plant shop can sell every seed type all year so the player is not locked out of important progression by the calendar.

The first playable farming step should be much smaller than full farming: one Moonleaf planter that pays off Sage's Moonleaf Seed Packet reward, advances through sleep/day changes, and produces a small Moonleaf harvest.

Long-term plant farming should use a grid system. There are two main planting places:

* Outside ground
* Greenhouse

Outside ground uses normal seasonal rules. Only plants that belong to the current
season can grow outside. Rainy or snowy days automatically water outside plants. Outside
crops die immediately on the first day of a new season if they are no longer in season.

The greenhouse does not get rainy-day or snowy-day watering, but it can grow plants from
any season. Greenhouse plants need manual watering unless Marigold has installed an
automation item.

The first magical watering item concept is **Nuage**, named from the French word for
cloud. Nuage is a small magical cloud that floats in the middle of a 3x3 farming grid
area and waters plants in the morning. Because it floats in the air, it does not occupy
the center planting space, so a plant can still grow beneath it. This makes the
greenhouse useful for reliable ingredient access without making it strictly easier than
outdoor farming.

Fruit trees are a longer-term crop type. They take one whole season to grow into mature
trees. Once mature, they produce seasonal fruit every day during their fruiting season.
If a fruit tree is planted outside, it survives out of season but does not bear fruit
outside its fruiting season. If a fruit tree is planted in the greenhouse, it produces
fruit all year round.

Fruit trees use the farming grid but take more space than normal crops. A tree takes a
3x3 grid area. Fruit trees can be replanted. If Marigold wants to remove one from its
current spot, she cuts it down with an axe.

Long-term, farming can include ordinary animals and magical monster keeping, but both
should support the crafting/shop loop instead of becoming the main game.

Normal farm animals should be limited to:

* Chicken
* Sheep
* Cow

Normal animal farming should focus on non-meat produce:

* Chickens produce eggs.
* Sheep produce wool.
* Cows produce milk.

Magical variants of eggs, wool, or milk can exist later if the world needs them.

Monster farming is a separate long-term system. Marigold can capture certain monsters
from caves and keep them in a monster farm on her property for regular produce. The
tone should be taming, not trapping. Marigold offers monster food; if the monster likes
it, and if there is an open monster-farm slot, it comes to the farm. If there is no
available slot, the monster cannot be tamed at that time.

Rarer monsters should be harder to tame and may require more monster food or repeated
successful feeding attempts. Tamed monsters do not help Marigold in battle. Their role
is to live on the property and provide magical crafting ingredients.

The monster farm should not produce meat. Instead, monsters provide magical crafting
ingredients related to their type, such as fairy dust from a fairy-like monster or
slime from a slime-like monster.

The same monster ingredients can also drop when Marigold defeats those monsters in the
cave. The monster farm exists as a more consistent, lower-risk way to get those
materials without requiring repeated cave trips. This keeps combat useful without making
it mandatory every time the player needs monster-derived ingredients.

Meat should not come from Marigold's farm or monster farm. Meat comes from slaying
monsters in the cave or buying from Alder.

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

Cave monsters can drop meat and monster-specific materials. Those monster-specific
materials should overlap with the future monster farm outputs, so players can choose
between active cave runs and steadier farm production.

Daily time and stamina should create gentle limits, not harsh pressure. They should help players choose what to do each day while still leaving room to wander, experiment, and enjoy the world.

If Marigold loses all HP, use a soft rescue instead of a hard fail state. She wakes up at home the next day with the village doctor nearby, loses a small amount of money, and starts later than usual. This should feel like Mapleton taking care of her, not like a punishment screen.

### World, Regions, and Long-Term Completion

Mapleton should be a compact village hub connected to authored regions. Exploration should expand by unlocking areas such as forest paths, caves, river areas, ruins, monster zones, and the ancient region through quest chains.

The deeper magical mystery should have a tone of gentle wonder. It can be ancient, strange, and emotional, but it should rarely feel dark or threatening.

The main long-term completion fantasy is **Thriving Mapleton**: Marigold becomes the reliable experienced witch of the village, restores or improves important facilities, unlocks regions, deepens relationships, and turns her shop into a beloved magical hub.

### Relationships, Romance, Homunculi, and Cafe

The core village cast should be roughly Stardew Valley-sized: large enough to feel like a community, but focused enough that important villagers can have portraits, routines, preferences, personal quests, and relationship arcs.

Romance is a major optional layer. It should have meaningful scenes and rewards, but the main game remains crafting, quests, and village restoration.

Homunculi are a mid-game automation system. They should unlock after the shop is established and help with shop, cafe, farm, storage, and repeat tasks. They are important to long-term progression, but should not appear before the core craft/quest/shop loop is stable. For farming, automation should progress from manual watering, to sprinkler-like magical items, to homunculi that can eventually handle watering through harvesting.

The cafe is an optional expansion. It should arrive later as a second business path using cooked recipes, but the magic shop remains Marigold's primary business.

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

### Preferred First Village Request NPC

Vertical Slice 0.2 should use **Sage**, the plant shop owner, as the first non-shop
quest NPC. Sage is warm, kind, gentle, quietly observant, knowledgeable about plants,
and a natural bridge from gathering/crafting into future seeds and farming advice.
For 0.2, use him only for a small authored plant-tonic request; do not add his romance
route, full plant shop, farming system, or NPC schedule yet.

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

Vertical Slice 0.8, **Shop Threshold and Arrival v1**, is implemented and
headless-verified. It adds a tiny front-of-shop exterior threshold and turns the shop
front door into a real player transition while keeping the full village, schedules, and
town systems out of scope.

The current priority is Vertical Slice 0.9, **Stackable Display and Customer Queue v1**:
one display can hold a stack of one sellable item, and a tiny sequential customer queue
can buy from that displayed stock one customer at a time. This should make Glowberry
Cordial useful in normal shop play after Camellia unlocks it, while avoiding direct
inventory sales, multiple displays, simultaneous customers, preferences, schedules,
reputation, price setting, or a full shop simulator.

The earlier posted-request idea is deferred until Marigold can personally deliver items
to requesters in a town/delivery space. Do not implement anonymous mailbox or
request-board turn-ins before that exists.

Do not expand directly into the full long-term feature set. Choose one next system or polish pass at a time, and keep each milestone testable inside the existing loop.

Near-term milestone candidates:

* Add stackable display stock plus a tiny sequential customer queue and keep the
  existing loop stable.
* Add data-driven NPC/dialogue loaders when ambient dialogue, schedules, or a third
  reusable quest visitor creates a concrete need.
* Add calendar seasons only when a seasonal item or gatherable needs them.
