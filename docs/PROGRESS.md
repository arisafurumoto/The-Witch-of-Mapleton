# The Witch of Mapleton — Progress & Handoff

> Living status doc. Read this first when starting a new session.
> Last updated: 2026-07-01.
> Milestone summaries: `docs/VERTICAL_SLICE_SUMMARY_0_1_TO_0_3_1.md` and
> `docs/VERTICAL_SLICE_SUMMARY_0_4_TO_0_6.md`.

## Status

**Vertical Slice 0.1 — "First Potion Sale" is complete and playable.** All 14 systems
from the implementation order are built (player movement → camera → collision →
interaction → scene transition → item db → inventory → gathering → crafting → shop
sale → dialogue → cat companion → save/load → day cycle). Real art is now in for the
characters (Marigold, Saffron, generic customer), the shop props (cauldron, bed,
counter, sign), the forest props (moonleaf bush, water spring, spring tree), and the
forest ground/path tiles. Action sound effects, styled DialogueBox/HUD, and a
customer enters/leaves polish are also in. Recent polish replaced the shop floor/walls,
added a first-pass forest ground detail overlay, gave Saffron simple idle glances, and
added small save/load HUD notifications. The project now boots to a simple title/start
menu before entering the playable slice.

**Vertical Slice 0.2 — "Sage's First Village Request" is complete and playable.** A
minimal quest database/system now tracks `sage_first_request`, Sage appears in the shop
on day 1, Root-Wake Tonic is brewed at the cauldron, Sage accepts the tonic, rewards
25 gold + a Moonleaf Seed Packet, walks out of the shop, and quest state is saved. The
HUD shows quest start/complete toasts and a small current-objective tracker. The tonic
and seed-packet inventory icons are in, and Sage has an updated sprite draft with walk
frames used for entering and leaving the shop.

**Vertical Slice 0.3.1 — "Known Recipe Cauldron UI" is complete and playable.**
Interacting with the cauldron now opens a compact known-recipe panel instead of
instantly crafting. Recipes are shown from `data/recipes.json`; recipes that cannot be
made with the current inventory remain selectable for preview, but Brew is disabled
until the ingredients are held. Selecting a recipe shows its ingredients/output and lets
the player choose how many batches to brew. Batch brewing uses
`CraftingSystem.craft_quantity()`. Root-Wake Tonic remains quest-gated and is capped to
one brew while Sage's request is active/ready. It now uses Dewcap Mushroom and Glowberry
so it no longer shares Calming Tea's ingredients.

**Vertical Slice 0.4 — "Quest and Recipe Guidance v1" is complete.** The active quest
tracker now shows Root-Wake Tonic ingredient progress while Sage's request is active
(`Dewcap Mushroom 0/1`, `Glowberry 0/2`) and updates as inventory changes. Once the tonic
is crafted, it switches back to the turn-in objective. Gatherables now show a short HUD
toast with the picked-up item name and quantity, and Dewcap Mushroom / Glowberry have
native 16x16 item icons for the inventory and cauldron detail rows.

**Vertical Slice 0.5 — "Shop Browsing Prototype v1" is complete and playable.** This
replaces the temporary manual sale with the first final-game-shaped shop loop:
Marigold stocks one Calming Tea on a display, opens the shop at the sign, the existing
customer walks to the display, chooses the item, walks to the counter, and waits for
checkout. Interacting with the customer at the counter consumes the display stock and
awards gold. Stocked display items are now saved and restored by stable display id. This
customer now uses four-direction walking art, Sage uses his eight-direction walking
art, and both NPCs follow a doorway waypoint when entering and leaving so they do not
cut through the north wall. Their movement and animation speeds match Marigold's
90 pixels/second and 12 fps. The customer routes around the counter and waits on its
public side for Marigold, while active Sage no longer replays his entrance after a
forest round trip, even if his quest has not been accepted. Chosen stock is reserved and
its display icon disappears while the customer carries it to checkout. This is
intentionally deterministic: no pricing UI, preferences, multiple customers, schedules,
or shop upgrades yet.
Stock now remains on its display overnight and through save/continue. Sleeping uses a
full-screen fade with a centered new-day announcement while the day advances and saves.

**Vertical Slice 0.6 — "Home Layout and Recipe Progression v1" is complete and
playable.** The shop now has separate forest, front visitor, and bedroom doors;
Marigold's bed and Saffron live in a separate room scene; the customer and Sage enter
through the front door; and the display/customer/counter route has been rebuilt around
the compact 720x480 shop and 540x360 bedroom. Sage and the customer wait directly along
the counter's public edge, with Sage facing the counter. Shop
display stock now lives in persistent global state, so sleeping and
saving from the room preserves unloaded shop stock. Calming Tea is known by default,
Sage's active quest temporarily exposes Root-Wake Tonic, and completing the quest
permanently unlocks and saves the recipe. Completed 0.5 saves migrate the recipe reward
without replaying quest rewards or notifications.
Saffron now enters each destination behind Marigold from the same doorway instead of
walking in from that scene's default placement.
Sage and the generic customer turn to face Marigold when she starts a conversation.
The final layout pass reduced the counter collider to its visible 96x32 base so
Marigold can comfortably attend visitors from behind it. Sage and browsing customers
now use the same centred counter position at different times: while Sage is present,
the shop sign reads `Visitor here` and refuses to open the browsing session.

**Vertical Slice 0.7 — "Camellia's First Request and Quest Chaining v1" is implemented,
headless-verified, and manually accepted.** Quest data now supports optional `required_quests` and
`minimum_day` fields, and Camellia's `camellia_first_request` is gated behind completed
`sage_first_request` plus Day 2. Glowberry Cordial is a new crafted-good item/recipe
made from Moonleaf, Glowberry, and Forest Water; it is temporarily visible while
Camellia's request is active/ready and permanently learned when the request is completed.
Camellia uses her packaged walking art, enters through the front visitor door, waits at
the existing public counter position, joins the `closed_shop_visitors` rule while
present, turns to face Marigold, rewards 30 gold, unlocks the recipe, and leaves through
the front door. The user played it and reported that it is working nicely on 2026-06-27.

**Vertical Slice 0.8 — "Shop Threshold and Arrival v1" is implemented and
headless-verified.** A compact front-of-shop exterior threshold scene now lets Marigold
leave through the shop front door, walk a bounded doorstep/path area, and re-enter the
shop. Saffron follows through both transitions, SaveSystem remains compatible with
outside scene/position restores, and the existing visitor/customer use of the interior
front-door markers is preserved. See
`docs/plans/vertical_slice_0_8_shop_threshold_and_arrival.md`.

**Vertical Slice 0.9 — "Stackable Display and Customer Queue v1" is implemented and
headless-verified.** The single shop display now holds a visible stack of one sellable
crafted item, adds one matching item per interaction, refuses to replace existing stock
with a different item, and persists through `ShopState`. Calming Tea remains stockable by
default, and Glowberry Cordial can be stocked/sold once its recipe is known. Opening the
shop plans a tiny sequential queue from displayed stock only, capped at three customers;
each customer reserves and buys exactly one displayed item, awards that item's sell
price, leaves through the front route, and only then allows the next customer to enter.
Active queue state is transient and not saved. See
`docs/plans/vertical_slice_0_9_stackable_display_customer_queue.md`.

**Vertical Slice 1.0 — "Mapleton Lane and First Hand Delivery v1" is implemented and
headless-verified, and manually accepted.** A compact placeholder `MapletonLane` scene
now sits beyond the shop exterior path, with a return transition, Saffron transition
placement, a single notice board, and Camellia waiting beside a simple restaurant stall.
The authored `camellia_cordial_delivery` request unlocks after
`camellia_first_request` is completed and Day 3 begins; Marigold accepts it from the
board, brings `glowberry_cordial` x2 to Camellia in person, receives 60 gold, and the
completed quest state persists through save data. The board is intentionally not a
menu/list system, and Mapleton Lane is only one bounded screen with placeholder shapes.
The user reported "That works great" on 2026-06-27. See
`tools/verify_vertical_slice_1_0.gd` and
`docs/plans/vertical_slice_1_0_mapleton_lane_hand_delivery.md`.

**Vertical Slice 1.1 — "Marigold's Notebook / Quest and Recipe Notes v1" is implemented
and headless-verified.** Pressing `J` opens a compact modal notebook over gameplay and
freezes Marigold's movement/interaction until the panel is closed with `J`, `Esc`, or
the close button. The notebook has two tabs: Quests and Recipes. Quests shows active or
ready quests first, completed quests below, requester/state/objective text, and clear
turn-in progress such as `Glowberry Cordial 1/2`. Recipes shows known default or
unlocked recipes, plus quest-active recipes while their quest is active/ready, with
station, output, ingredient owned/needed counts, and `Ready` / `Missing ingredients`
status. It reads from existing quest, recipe, recipe-knowledge, inventory, and item
data; no save data, new content, full journal, map markers, portraits, relationship UI,
calendar, recipe discovery, new quests, new recipes, or new areas were added. See
`docs/plans/vertical_slice_1_1_notebook_notes.md`.

**Vertical Slice 1.2 — "Sage's Posted Delivery and Lane Presence v1" is implemented and
headless-verified.** The notice board now supports a tiny deterministic authored quest
sequence while keeping the existing `quest_id` compatibility path. After Camellia's
delivery is completed and Day 4 begins, the board offers Sage's
`sage_seedling_restock` request: Marigold brews one existing Root-Wake Tonic and turns
it in to Sage at a small placeholder plant stall in the existing Mapleton Lane scene.
The quest rewards 45 gold, persists through existing quest save data, and appears in
the notebook with Root-Wake Tonic progress. No new items, recipes, gathering nodes,
farming, plant-shop gameplay, schedules, new NPCs, new areas, reputation, relationship
points, deadlines, quality requirements, request-board menu, or repeatable job system
were added. See
`docs/plans/vertical_slice_1_2_sage_posted_delivery.md`.

**Vertical Slice 1.3 — "Forest Path Unlock and Brookmint Tea v1" is implemented and
headless-verified.** Completing `sage_seedling_restock` now unlocks a small
`ForestPath` scene from the existing forest clearing. The path has two daily Brookmint
patches, a return transition, camera limits, boundaries, and Saffron transition
placement. Camellia's Day 5 notice-board request `camellia_brookmint_request` asks for
Brookmint Tea, a new quest-active cauldron recipe made from Brookmint x2 and Forest
Water x1; completing the request awards 80 gold and permanently learns the recipe.
Lane Camellia now supports a tiny ordered quest list while keeping the old `quest_id`
compatibility field. No full forest region, multiple new screens, seasons, farming,
combat, new NPCs, schedules, board menu, repeatable requests, map UI, item quality, or
shop-pricing/customer-preference systems were added. See
`tools/verify_vertical_slice_1_3.gd` and
`docs/plans/vertical_slice_1_3_forest_path_brookmint.md`.

**Vertical Slice 1.4 — "Dialogue Portraits v1" is implemented and headless-verified.**
`DialogueBox` now uses a larger reference-style portrait layout: the active character
portrait stands on the lower-left of the screen with a separate nameplate, while the
dialogue box shifts right and remains readable. A follow-up pass puts Marigold's
portrait/nameplate on the lower-right while NPC portraits stay on the lower-left, and
clears the portrait/nameplate when dialogue closes. Dialogue still supports the old
`show_dialogue(speaker, lines)` string-array API, and now also accepts optional per-line
dictionaries with `speaker`, `expression`, and `text` so conversations can alternate
between NPCs and Marigold. Marigold, Sage, and Camellia use existing
default/thinking/concerned/laugh-style portrait exports where available; speakers
without portrait art, such as Notice Board and Villager, cleanly hide the portrait slot.
Sage and Camellia quest conversations now include a few Marigold replies for a more
natural back-and-forth. No new portrait art, relationship UI, branching
conversation choices, visual-novel cutscenes, full dialogue database rewrite, or NPC
database migration were added. See
`tools/verify_vertical_slice_1_4.gd` and
`docs/plans/vertical_slice_1_4_dialogue_portraits.md`.

**Rough roadmap:** The current near-term direction is Marigold's first week in Mapleton:
next add map blockout/readability, focused tileset and prop passes, a tiny Moonleaf
planter payoff, and then more shop variety. Keep full town systems, schedules,
relationships, seasons, full farming, combat, item quality, shop pricing, cafe, and
Homunculi deferred until the quest/crafting/shop loop has more weight. See
`docs/plans/vertical_slice_roadmap.md`.

Engine: **Godot 4.1.3** at `/Applications/Godot.app`. Main scene: `scenes/ui/TitleMenu.tscn`.

Long-term vision notes now live in `docs/GDD.md`: **Atelier series meets cosy life
sim**, with Atelier-style gathering/crafting/quests as the main progression, optional
Moonlighter-style shop management, calendar seasons, limited farming, separate
shop/room scenes, cooking/cafe progression, and simple supportive combat. These are
future design directions and should not expand the current vertical-slice scope.
Recent ideation notes added to `docs/GDD.md` and `docs/CHARACTERS.md`: Karazon is a
large online shopping corporation with no Mapleton storefront, its CEO is originally
from Mapleton and is still the current CEO, Linden works for Karazon remotely, and
Anemone's interest in money/business started after meeting the CEO before he founded the
company. Karazon/technology is a long-term philosophical rival to Marigold's handmade
shop: convenient next-day delivery and free shipping versus human touch, love, and
community. Long-term farming can include ordinary chickens/sheep/cows plus a separate
monster farm on Marigold's property for magical produce. Monster capture is taming via
monster food, open farm slots, and rarer monsters needing more food. Farm and
monster-farm systems should not produce meat; meat comes from cave monster slaying or
buying from Alder. Weather should eventually stay simple: mostly sunny, less-common
rain, and snow replacing rain in winter, with forecasts available on the radio. Rain or
snow automatically waters outside plants, including winter crops; greenhouse plants get
no weather benefit but can grow any seasonal plant if manually watered or automated.
Outside crops die immediately on the first day of a new season if they are no longer in
season. Fruit trees take one whole season to mature, occupy a 3x3 grid area, can be
replanted, produce daily fruit in season, and produce year-round if planted in the
greenhouse. Magical item names can selectively use French words as Atelier-style
language flavour. The first sprinkler-like magical item concept is **Nuage**, a small
cloud named from the French word for cloud; its mechanical rule is 3x3 coverage in the
morning while floating above the center tile so the center planting space remains
usable. Farming automation can progress from manual watering to Nuage-like magical
items to homunculi handling watering and harvesting.
Additional locked design direction: progression is driven mainly by quest chains;
alchemy quality/traits should have readable depth; daily time/stamina should be gentle;
the world is a compact hub with unlocked authored regions; the cast should be roughly
Stardew Valley-sized; romance is a major optional layer; Homunculi are mid-game
automation; the cafe is an optional expansion; the mystery tone is gentle wonder; the
long-term completion fantasy is a thriving Mapleton. Saffron is a home-property
companion in the full design: he speaks early, later mostly meows, stays around the
shop/room/farm/cafe, eventually meets a white village cat, and may have kittens. If
Marigold loses all HP, she wakes at home the next day with the doctor nearby, loses a
small amount of money, and starts later than usual.
Marigold's updated default visual direction is now an autumn village-witch design:
long copper-orange hair, olive hat, moss-green layered dress, cream puff sleeves,
rust-orange shawl, brown boots, and an amber-crystal staff. Future outfit changing is
planned, but not part of the current slice.
Saffron's concept direction is a small black cat with large golden-amber eyes,
oversized triangular ears, warm dark-brown fur highlights, an expressive curled tail,
and an olive collar with a gold-framed amber crystal pendant.

## How to run & verify

```bash
# Headless import (run after adding/renaming art or on a fresh checkout)
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --quit

# Headless load/parse check (should print no ERROR lines; warnings are treated as errors)
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit

# Focused 0.6 state/layout acceptance check
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_0_6.gd

# Focused 0.7 quest-chaining acceptance check
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_0_7.gd

# Focused 0.8 exterior threshold acceptance check
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_0_8.gd

# Focused 0.9 stackable display / customer queue acceptance check
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_0_9.gd

# Focused 1.0 Mapleton Lane / hand delivery acceptance check
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_0.gd

# Focused 1.1 notebook / quest and recipe notes acceptance check
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_1.gd

# Focused 1.2 Sage posted delivery / lane presence acceptance check
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_2.gd

# Focused 1.3 forest path / Brookmint Tea acceptance check
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_3.gd

# Focused 1.4 dialogue portrait acceptance check
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tools/verify_vertical_slice_1_4.gd

# Play the game
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

## The playable loop

0.2/0.3.1 quest loop: start in the shop → talk to Sage → go through the top door to the
forest → gather Dewcap Mushroom (×1) and Glowberry (×2) → return → brew Root-Wake Tonic
at the cauldron by selecting the known recipe in the panel → talk to Sage → receive
25 gold + Moonleaf Seed Packet → sleep in the bed → day advances, game saves, quest
completion persists.

0.5 shop-sale loop: start in the shop → gather Moonleaf (×2) and Forest Water (×1) →
return and craft Calming Tea → stock the display → open the shop at the sign → customer
enters, browses, chooses the tea, and waits at the public side of the counter → attend
from behind the counter → receive 18 gold → sleep → stocked displays persist, the day
advances with a full-screen transition, and the game saves.

0.6 home/progression loop: use the top forest door and right-side room door while the
front door remains visitor-only → stock Calming Tea → sleep and save in Marigold's room
without losing shop stock → start Sage's request to temporarily reveal Root-Wake Tonic
at the cauldron → complete the request to permanently learn the recipe → sleep and
continue with the learned recipe and room position restored.

0.7 quest-chaining loop: complete Sage's request → sleep to Day 2 → return to the shop
and see Camellia enter through the front visitor door → accept **A Brighter Menu** →
brew one Glowberry Cordial from Moonleaf (×1), Glowberry (×2), and Forest Water (×1) →
turn it in to Camellia → receive 30 gold, permanently learn Glowberry Cordial, and see
Camellia leave → sleep/continue and confirm the completed quest and learned recipe
persist.

0.8 threshold loop: start in the shop → use the front door → arrive in a tiny
shop exterior threshold scene → walk the bounded front step/path area → re-enter the
shop → confirm Saffron follows both ways and save/continue restores the exterior if the
game is saved outside.

0.9 shop loop: craft multiple copies of Calming Tea or unlocked Glowberry
Cordial → stock the single display repeatedly until it shows a stack such as `x3` →
open the shop → serve customers one at a time as each buys one displayed item → confirm
display stock and gold update per sale → sleep/continue and confirm remaining display
stock persists.

1.0 delivery loop: complete Camellia's first request → sleep to Day 3 → leave the shop
exterior for tiny Mapleton Lane → read the notice board → accept
`camellia_cordial_delivery` → craft or carry Glowberry Cordial x2 → talk to Camellia at
the restaurant stall → hand over the cordials in person → receive 60 gold →
sleep/continue and confirm completion persists.

1.1 notebook loop: press `J` during gameplay → review active/ready quests and completed
history on the Quests tab → switch to Recipes to review known and quest-active recipes,
ingredient counts, and brew readiness → close with `J` or `Esc` and confirm movement
resumes.

1.2 Sage delivery loop: complete `camellia_cordial_delivery` → sleep to Day 4 → go to
Mapleton Lane → read the notice board → accept `sage_seedling_restock` → brew or carry
Root-Wake Tonic x1 → deliver it to Sage at the placeholder plant stall → receive 45
gold → sleep/continue and confirm completion persists.

1.3 Brookmint loop: complete `sage_seedling_restock` → sleep to Day 5 → read the
Mapleton Lane notice board → accept **A Fresh Pot** → go to the forest clearing → use
the newly unlocked forest path → gather Brookmint x2 → return to the shop → brew
Brookmint Tea → open the notebook and confirm quest/recipe counts are readable →
deliver Brookmint Tea to Camellia in Mapleton Lane → receive 80 gold and permanently
learn Brookmint Tea → sleep/continue and confirm completion persists.

1.4 portrait check: trigger dialogue with Marigold, Sage, or Camellia and confirm the
large portrait appears with a nameplate; advance through a quest conversation and
confirm NPC portraits use the lower-left, Marigold replies use the lower-right, and the
portrait/expression switches by speaker; finish the conversation and confirm the
portrait/nameplate disappear; read the notice board or serve a generic customer and
confirm the portrait slot hides cleanly for speakers without portrait art.

## Architecture

**Autoload singletons** (order matters — defined in `project.godot`):
`ItemDatabase`, `Inventory`, `RecipeDatabase`, `RecipeKnowledgeSystem`, `CraftingSystem`,
`ShopRequestDatabase`, `ShopSystem`, `ShopState`, `AudioSystem`, `QuestDatabase`,
`QuestSystem`, `DialogueBox` (UI scene),
`DaySystem`, `HUD` (UI scene), `InventoryPanel` (UI scene), `CauldronCraftingPanel`
(UI scene), `NotebookPanel` (UI scene), `SaveSystem` (last, so it loads after the systems
it writes into).
`Inventory` holds items **and** gold and persists across scene changes.
`DaySystem` holds the day + per-gatherable depletion state. `QuestSystem` stores quest
states (`not_started`, `active`, `ready_to_turn_in`, `completed`) and checks small
quest availability gates from data (`required_quests`, `minimum_day`). `SaveSystem` stores
inventory, gold, day/gatherable state, quests, known recipes, persistent shop stock,
current scene path, and player position, then restores the player position when the
saved scene's player is ready. `ShopState` owns stable display stock independently of
loaded scenes. `RecipeKnowledgeSystem` owns quest-unlocked recipes; default-known recipes
remain data-driven and are not duplicated in save data.

**Interaction pattern:** `scripts/core/Interactable.gd` (Area2D, has `interact()`,
`show_prompt()`, optional inline `dialogue`). Subclasses: `Door`, `Gatherable`,
`CraftingStation`, `Bed`, `scripts/npc/CustomerNPC.gd`, `scripts/npc/SageNPC.gd`, and
`scripts/npc/CamelliaNPC.gd`. The player
(`scripts/player/PlayerController.gd`) detects nearby interactables via an Area2D and
calls `interact()` on the nearest; movement/interaction freeze while dialogue, the
cauldron crafting panel, or the new-day transition is active. `DialogueBox` keeps the
same `show_dialogue(speaker, lines)` API for string arrays, can also consume per-line
dialogue dictionaries (`speaker`, `expression`, `text`), and maps known speaker names
to optional portrait art internally.

**Data-driven content** (JSON loaders validate on load): `data/items.json`,
`data/recipes.json`, `data/shop_requests.json` (customer request + inline dialogue lines),
and `data/quests.json` (Sage/Camellia quest gates, turn-ins, rewards, and dialogue).

**Scenes:** `scenes/world/{ShopInterior,MarigoldRoom,ForestClearing,ForestPath,ShopExterior,MapletonLane}.tscn` (Y-sort enabled),
reusable `scenes/world/{Door,Gatherable}.tscn`, `scenes/npc/{Cat,Camellia}.tscn`,
`scenes/player/Player.tscn`,
`scenes/ui/{DialogueBox,HUD,InventoryPanel,CauldronCraftingPanel,NotebookPanel}.tscn`.
Slice 1.0 adds `scripts/core/NoticeBoard.gd` and the lane-specific
`scripts/npc/CamelliaLaneNPC.gd`; slice 1.2 extends the board to a tiny authored
sequence and adds `scripts/npc/SageLaneNPC.gd`; slice 1.3 adds
`scripts/core/QuestLockedDoor.gd` and extends lane Camellia to choose from a small
ordered quest list.

## Art pipeline & conventions (IMPORTANT — learned the hard way)

The user now supplies finished separated runtime PNG frames for humanoid characters.
Codex does not generate source images, crop, resize, downscale, pad, reposition,
recolour, clean, or repaint the supplied frames. It only packages existing frames into
Godot `SpriteFrames` `.tres` resources with `tools/build_character_spriteframes.py`.

Current active character resources:
- **Marigold:** `art/characters/marigold/default/` packaged as
  `art/characters/marigold/Marigold.tres`; default dialogue portrait at
  `art/characters/marigold/portraits/default.png`, with concerned/thinking/laugh
  expression portraits also available.
- **Generic customer:** `art/characters/npcs/generic_customer/young_man/` packaged as
  `art/characters/npcs/generic_customer/GenericCustomer.tres`.
- **Sage:** `art/characters/npcs/sage/` packaged as
  `art/characters/npcs/sage/Sage.tres`; default dialogue portrait at
  `art/characters/npcs/sage/portraits/default.png`, with neutral/concerned/thinking/
  laugh/blushed expression portraits also available.
- **Camellia:** `art/characters/npcs/camellia/` packaged as
  `art/characters/npcs/camellia/Camellia.tres` and instantiated as the 0.7 quest visitor;
  default dialogue portrait at `art/characters/npcs/camellia/portraits/default.png`,
  with concerned/thinking/laugh/blushed expression portraits also available.

Rules:
1. **Runtime humanoid frame standard:** eight direction folders (`east`, `south-east`,
   `south`, `south-west`, `west`, `north-west`, `north`, `north-east`), one idle PNG
   per direction under `rotations/`, and six walk frames per direction under
   `animations/walking/` or `animations/Walking/`.
2. **Never overwrite/resample source art in place.** Humanoid PNG frames are final
   user-supplied runtime art. Existing high-resolution art continues to scale only at
   display time with the Nearest filter.
   - **Marigold:** 164px frames, `AnimatedSprite2D` `scale = 1.0`, offset `(0,-40)`.
   - **Generic customer:** 172px frames, `AnimatedSprite2D` `scale = 0.63`, offset `(0,-28)`.
   - **Sage:** 168px frames, `AnimatedSprite2D` `scale = 1.0`, offset `(0,-40)`.
   - **Camellia:** 168px frames, `AnimatedSprite2D` `scale = 1.0`, offset `(0,-40)`.
   - **Saffron (cat):** 68px frames authored ~native, `scale = 1.0`, offset `(0,-17)`.
3. **Direction mapping lives in the `.tres`/packager, not in guesswork.** The packager
   maps each `walk_<dir>` animation to a source folder. Marigold currently uses the
   **identity** mapping (folder name = direction) because the art folders are correctly
   organised. If a character faces the wrong way, fix the folder→animation mapping in the
   packager — **trust the in-game observation over reading the frames.** (We lost time
   applying a wrong "mirror" remap; reverted to identity.)
4. **Feet/base at bottom-centre of the canvas**; set the sprite offset so the feet sit at
   the node origin. Y-sort uses node position, so this keeps depth + collision aligned.
5. Project setting `textures/canvas_textures/default_texture_filter = 0` (Nearest) — keep it.

## Backups & safety

- `backups/` holds local art snapshots; it has a `.gdignore` (Godot skips it) and is
  git-ignored. See `backups/README.md`. Snapshots are taken before destructive art ops.
- **The repo is committed through 0.9** (latest implementation commit at handoff:
  `db8d4cb`). Keep committing after each focused batch — it's the real safety net (an
  early loss of crisp Marigold frames predates the baseline). `.gitignore` excludes
  `.godot/`, `backups/`, and keeps `*.import` files.
- Current handoff note for the next session: the worktree contains the uncommitted 1.1
  notebook implementation/docs, the uncommitted 1.2 Sage delivery implementation/docs,
  the uncommitted 1.3 forest path/Brookmint implementation/docs, and the uncommitted 1.4
  dialogue portrait implementation/docs. Before starting the next slice, run the
  0.6-1.4 verifiers and consider committing the current focused batch.

## Next steps / backlog

- [x] Expanded rough roadmap for slices 1.3+ and art/world/farming production tracks.
      See `docs/plans/vertical_slice_roadmap.md`. Current recommendation: add map
      blockout/readability, focused tileset and prop passes, a tiny Moonleaf planter
      payoff, and then more shop variety. Treat it as guidance, not a locked
      implementation contract. Done 2026-06-28; updated 2026-07-01 after 1.4.
- [ ] Manual 1.4 acceptance playthrough in the Godot editor.
- [x] Vertical Slice 1.4 — Dialogue Portraits v1.
      See `docs/plans/vertical_slice_1_4_dialogue_portraits.md`. Added a larger
      lower-left DialogueBox portrait/nameplate layout, speaker-name and expression
      lookup for existing Marigold, Sage, and Camellia portrait art, optional per-line
      dialogue dictionaries, and a few Marigold replies in quest conversations. Follow-up
      feedback put Marigold's portrait/nameplate on the right and fixed portrait cleanup
      after dialogue closes. Speakers without portrait art use a clean no-portrait
      fallback. No new art, relationship UI, branching dialogue choices, or NPC database
      migration was added. Done 2026-07-01; see `tools/verify_vertical_slice_1_4.gd`.
- [ ] Manual 1.3 acceptance playthrough in the Godot editor.
- [x] Vertical Slice 1.3 — Forest Path Unlock and Brookmint Tea v1.
      See `docs/plans/vertical_slice_1_3_forest_path_brookmint.md`. Added one
      quest-gated forest path, two Brookmint gatherables, one Brookmint Tea recipe, and
      one Camellia request after Sage's restock quest. Kept it to a single tiny new scene
      and existing systems; no full forest, seasons, farming, combat, new NPCs,
      schedules, board menu, repeatable requests, map UI, quality, or shop-pricing
      systems. Done 2026-06-30; see `tools/verify_vertical_slice_1_3.gd`.
- [ ] Manual 1.2 acceptance playthrough in the Godot editor.
- [x] Vertical Slice 1.2 — Sage's Posted Delivery and Lane Presence v1.
      See `docs/plans/vertical_slice_1_2_sage_posted_delivery.md`. Add one sequential
      board request after Camellia's delivery, a static Sage plant-stall presence in
      Mapleton Lane, and the smallest notice-board extension needed to choose between
      authored requests. Reuse Root-Wake Tonic and existing Sage art. Do not add new
      items, recipes, gathering nodes, farming, plant-shop gameplay, schedules, a board
      menu, repeatable requests, new NPCs, or new areas. Done 2026-06-28; see
      `tools/verify_vertical_slice_1_2.gd`.
- [ ] Manual 1.1 acceptance playthrough in the Godot editor.
- [x] Vertical Slice 1.1 — Marigold's Notebook / Quest and Recipe Notes v1.
      See `docs/plans/vertical_slice_1_1_notebook_notes.md`. Add a compact notebook UI
      with Quests and Recipes tabs so the player can review current objectives,
      completed quests, known recipes, ingredient counts, and brew readiness. Keep it
      read-only and data-driven from existing quest, recipe, inventory, and recipe
      knowledge systems. Do not add new quests, recipes, map markers, a calendar,
      relationship UI, recipe discovery, or a broad journal framework. Done 2026-06-28;
      see `tools/verify_vertical_slice_1_1.gd`.
- [x] Manual 1.0 acceptance playthrough in the Godot editor. The user reported "That
      works great" after playing the Mapleton Lane delivery loop on 2026-06-27.
- [x] Vertical Slice 1.0 — Mapleton Lane and First Hand Delivery v1.
      See `docs/plans/vertical_slice_1_0_mapleton_lane_hand_delivery.md`. One tiny
      `MapletonLane` scene beyond the shop exterior, one notice-board request, and one
      in-person Camellia delivery for `glowberry_cordial` x2 are implemented. Reuses
      existing quest, inventory, dialogue, transition, save/load, and Camellia art
      patterns. No full village, restaurant interior, schedules, repeatable board,
      mailbox turn-ins, relationships, reputation, new recipes, or new NPCs were added.
      Done 2026-06-27; see `tools/verify_vertical_slice_1_0.gd`.
- [x] Vertical Slice 0.9 — Stackable Display and Customer Queue v1.
      See `docs/plans/vertical_slice_0_9_stackable_display_customer_queue.md`. Let the
      single display hold a stack of one sellable item, allow unlocked Glowberry Cordial
      to be stocked and sold, and serve a tiny sequential customer queue from displayed
      stock only. Do not add direct inventory sales, mixed display items, multiple
      displays, simultaneous customers, preferences, schedules, reputation, price
      setting, town delivery, posted requests, or queue save/load. Done 2026-06-27; see
      `tools/verify_vertical_slice_0_9.gd`.
- [x] Vertical Slice 0.8 — Shop Threshold and Arrival v1.
      See `docs/plans/vertical_slice_0_8_shop_threshold_and_arrival.md`. Add one tiny
      front-of-shop exterior threshold, wire the shop front door as a player transition,
      preserve visitor/customer routing, verify Saffron follows, and confirm save/load
      from outside. Do not add the village map, NPC schedules, new quests, restaurant,
      plant shop, farming, weather, or town systems. Done 2026-06-27; see
      `tools/verify_vertical_slice_0_8.gd`.
- [x] Manual 0.7 acceptance playthrough in the Godot editor. The user reported the 0.7
      flow is working nicely on 2026-06-27.
- [x] Vertical Slice 0.7 — Camellia's First Request and Quest Chaining v1.
      One Day 2 prerequisite-gated Camellia request, one Glowberry Cordial item/recipe,
      one permanent recipe unlock, one focused Camellia visitor, and closed-shop visitor
      coordination are in. The village exterior, restaurant gameplay, relationships,
      schedules, new gathering regions, and a broad NPC system remain out of scope. Done
      2026-06-27; see `tools/verify_vertical_slice_0_7.gd`.
- [x] Vertical Slice 0.6 — Home Layout and Recipe Progression v1. Persistent shop state,
      separate room, three shop doors, visitor route updates, saved recipe knowledge,
      Sage's recipe reward, HUD feedback, and 0.5 save migration are complete. The front
      exterior, room decoration, pricing, schedules, and recipe-book UI remain out of
      scope. Done 2026-06-18.
- [x] Vertical Slice 0.5 — Shop Browsing Prototype v1.
      See `docs/plans/vertical_slice_0_5_shop_browsing_prototype.md`. Keep it focused:
      one display, one customer, one stockable item, one checkout interaction. Do not add
      price setting, multiple displays, multiple customers, preferences, schedules, or
      shop upgrades. Done 2026-06-18.
- [x] Vertical Slice 0.4 — Quest and Recipe Guidance v1.
      See `docs/plans/vertical_slice_0_4_quest_recipe_guidance.md`. Keep it focused:
      ingredient progress in the quest tracker, clearer gather feedback, and small item
      icons for Dewcap Mushroom and Glowberry. Do not add a full quest journal, recipe
      book, new quest chain, or new NPC. Done 2026-06-17.
- [x] Vertical Slice 0.3.1 — Known Recipe Cauldron UI. The cauldron panel now lists
      known recipes, lets unavailable known recipes be selected for missing-ingredient
      preview, disables only Brew until ingredients are held, and supports capped batch
      brewing with `-` / `+`. Follow-up content pass added Dewcap Mushroom and
      Glowberry gatherables and moved Root-Wake Tonic onto those ingredients. Done
      2026-06-17.
- [x] Vertical Slice 0.3 — Cauldron Crafting UI / Ingredient Selection v1. The
      cauldron opens `CauldronCraftingPanel`, inventory items can be added/removed from
      a selected tray, Brew exact-matches cauldron recipes, failed mixes preserve
      ingredients, and player movement pauses while the panel is open. Done 2026-06-17.
- [x] Vertical Slice 0.2 — Sage's First Village Request. Minimal quest state, Sage's
      authored interaction, Root-Wake Tonic, rewards, save/load support, quest HUD
      feedback, Sage exit polish, and Sage art are in. Sage appears on day 1, and
      Root-Wake Tonic now brews at the cauldron rather than a potting bench. Done
      2026-06-17.
- [x] Root-Wake Tonic / Moonleaf Seed Packet icons — native 16×16 pixel icons at
      `art/items/<id>.png`. The inventory panel now shows art for all 0.2 items instead
      of fallback swatches. Done 2026-06-17.
- [x] Quest UX feedback — HUD toast on quest start/completion plus a small active quest
      tracker showing the current Sage objective (`Craft Root-Wake Tonic` or
      `Bring Root-Wake Tonic to Sage`). No full quest journal yet. Done 2026-06-17.
- [x] Compact UI scale pass — reduced gameplay HUD, quest tracker, dialogue box,
      inventory panel, and title menu type/padding/panel sizes so the UI takes up less
      of the 640×360 view. Follow-up trimmed the HUD/tracker further. Done 2026-06-17.
- [x] Sage turn-in exit polish — Sage now uses his walking frames to enter the shop and
      walk upward out after Root-Wake Tonic is delivered instead of disappearing
      instantly. Done 2026-06-17.
- [x] Initial git baseline exists; continue committing after focused art/system batches.
- [x] Cauldron & bed sprites (milestone 0.2a) — `art/props/shop/{cauldron,bed}.png`
      (native 72×56 / 72×44, scale 1.0) replace the `Polygon2D` "Visual" nodes in
      `ShopInterior.tscn`; zones/scripts/collision unchanged. Done 2026-06-16.
- [x] Forest gatherable sprites — `art/props/forest/{moonleaf_bush,forest_water_spring}.png`
      replace the reusable gatherable `Visual`; zones/scripts/collision unchanged.
      Done 2026-06-16.
- [x] Generic customer sprite — `art/characters/npcs/generic_customer/young_man/`
      now feeds `GenericCustomer.tres`; sale request logic/collision unchanged.
      Updated 2026-06-27.
- [x] Shop sign sprite — `art/props/shop/shop_sign.png` replaces the sign `Polygon2D`;
      sign dialogue/collision unchanged. Done 2026-06-16.
- [x] Shop counter sprite — `art/props/shop/shop_counter.png` replaces the central
      `ObstacleVisual`; obstacle collision unchanged. Done 2026-06-16.
- [x] Spring forest tree sprite — `art/props/forest/tree_spring_1.png` replaces the
      forest tree polygons; trunk collision unchanged. First season visual direction is
      spring. Done 2026-06-16.
- [x] Forest spring ground tile pass — `art/tilesets/forest/*spring*` source tiles build
      repeated `art/backgrounds/forest/*spring*.png` ground/path layers for
      `ForestClearing.tscn`; collisions unchanged. Done 2026-06-16.
- [x] UI readability pass — styled `DialogueBox` and `HUD` with warm dark panels and
      readable text; signals/data flow unchanged. Done 2026-06-16.
- [x] Basic audio feedback — `AudioSystem` autoload plays short gather, craft, sale, and
      sleep cues from existing success points. No music/settings menu yet. Done 2026-06-16.
- [x] Customer enters/leaves polish — the first customer stays hidden until Calming Tea
      is crafted, then fades/slides in; after a successful sale they leave. One customer
      only; no schedules/queues. Done 2026-06-16.
- [x] Inventory panel — `scenes/ui/InventoryPanel.tscn` + `scripts/ui/InventoryPanel.gd`
      (autoload UI scene). Non-modal panel toggled with the **I** key (`toggle_inventory`
      action), top-right, styled to match the HUD. Rebuilds on `inventory_changed`; each
      row shows the item icon if `art/items/<id>.png` exists, else a colored fallback
      swatch. Done 2026-06-16.
- [x] Item icons (Moonleaf / Forest Water / Calming Tea) — native 16×16 pixel icons at
      `art/items/<id>.png`. The inventory panel displays them automatically in place of
      placeholder swatches. Done 2026-06-16.
- [x] Shop floor/walls pass — `art/backgrounds/shop/{shop_walls,shop_floor}.png`
      replace the large `Polygon2D` background/floor rectangles in `ShopInterior.tscn`;
      collision, props, doors, and interaction zones unchanged. Done 2026-06-16.
- [x] Broader forest detail pass — `art/backgrounds/forest/forest_detail_spring.png`
      adds non-colliding ground detail over the grass/path layer in `ForestClearing.tscn`
      (tufts, flowers, stones, mushrooms, leaf clusters); gameplay zones unchanged.
      Done 2026-06-16.
- [x] Polish: cat idle animation variety — Saffron now occasionally changes idle facing
      while waiting near Marigold, sometimes glancing toward her and sometimes looking
      around. No new art frames; follow behavior unchanged. Done 2026-06-16.
- [x] Restore player position/current scene on load — save data now includes
      `current_scene` and `player_position`; old saves still load with safe defaults.
      Done 2026-06-16.
- [x] Save UX/debug polish — `SaveSystem` emits `game_saved` / `game_loaded` signals;
      `HUD` shows a short "Game saved" or "Loaded Day X" toast while console debug
      prints remain in place. Done 2026-06-16.
- [x] Title/start menu — `project.godot` now starts at `scenes/ui/TitleMenu.tscn`,
      with Continue, New Game, and Quit buttons over a placeholder pixel title
      background. Continue restores the saved scene/position; New Game clears the save
      and starts in the shop. Done 2026-06-16.
- [x] Door transition spawn positions — shop/forest doors now pass a one-shot target
      player position, so returning from the forest places Marigold just inside the shop
      door instead of at the scene default. Done 2026-06-17.
- [ ] Deferred from the slice: `npcs.json` + NPC database; a dialogue-id database
      (lines are currently inline in `shop_requests.json`). Consider this when adding a
      second customer/NPC or more than one reusable dialogue, not for the one-request
      vertical slice.

## Known quirks

- GDScript **warnings are treated as errors** — avoid `Variant` inference (use typed vars,
  `minf`/`maxi`, etc.).
- `.tscn` `load_steps` is a hint; keep it ≥ actual resource count when hand-editing.
- After renaming/adding art files, run the headless `--editor --quit` import pass before
  playing (renames can leave stale `.import` files).
