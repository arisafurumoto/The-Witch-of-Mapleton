# The Witch of Mapleton — Progress & Handoff

> Living status doc. Read this first when starting a new session.
> Last updated: 2026-06-20.
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

**Vertical Slice 0.7 — "Camellia's First Request and Quest Chaining v1" is planned.**
This will add one prerequisite-gated Day 2 quest, one Glowberry Cordial item/recipe made
from existing ingredients, and one Camellia shop visit that joins the existing
closed-shop visitor rule. See
`docs/plans/vertical_slice_0_7_camellia_quest_chaining.md`.

Engine: **Godot 4.1.3** at `/Applications/Godot.app`. Main scene: `scenes/ui/TitleMenu.tscn`.

Long-term vision notes now live in `docs/GDD.md`: **Atelier series meets cosy life
sim**, with Atelier-style gathering/crafting/quests as the main progression, optional
Moonlighter-style shop management, calendar seasons, limited farming, separate
shop/room scenes, cooking/cafe progression, and simple supportive combat. These are
future design directions and should not expand the current vertical-slice scope.
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

## Architecture

**Autoload singletons** (order matters — defined in `project.godot`):
`ItemDatabase`, `Inventory`, `RecipeDatabase`, `RecipeKnowledgeSystem`, `CraftingSystem`,
`ShopRequestDatabase`, `ShopSystem`, `ShopState`, `AudioSystem`, `QuestDatabase`,
`QuestSystem`, `DialogueBox` (UI scene),
`DaySystem`, `HUD` (UI scene), `InventoryPanel` (UI scene), `CauldronCraftingPanel`
(UI scene), `SaveSystem` (last, so it loads after the systems it writes into).
`Inventory` holds items **and** gold and persists across scene changes.
`DaySystem` holds the day + per-gatherable depletion state. `QuestSystem` stores quest
states (`not_started`, `active`, `ready_to_turn_in`, `completed`). `SaveSystem` stores
inventory, gold, day/gatherable state, quests, known recipes, persistent shop stock,
current scene path, and player position, then restores the player position when the
saved scene's player is ready. `ShopState` owns stable display stock independently of
loaded scenes. `RecipeKnowledgeSystem` owns quest-unlocked recipes; default-known recipes
remain data-driven and are not duplicated in save data.

**Interaction pattern:** `scripts/core/Interactable.gd` (Area2D, has `interact()`,
`show_prompt()`, optional inline `dialogue`). Subclasses: `Door`, `Gatherable`,
`CraftingStation`, `Bed`, `scripts/npc/CustomerNPC.gd`, and `scripts/npc/SageNPC.gd`. The player
(`scripts/player/PlayerController.gd`) detects nearby interactables via an Area2D and
calls `interact()` on the nearest; movement/interaction freeze while dialogue, the
cauldron crafting panel, or the new-day transition is active.

**Data-driven content** (JSON loaders validate on load): `data/items.json`,
`data/recipes.json`, `data/shop_requests.json` (customer request + inline dialogue lines),
and `data/quests.json` (Sage quest turn-in/reward/dialogue).

**Scenes:** `scenes/world/{ShopInterior,MarigoldRoom,ForestClearing}.tscn` (Y-sort enabled),
reusable `scenes/world/{Door,Gatherable}.tscn`, `scenes/npc/Cat.tscn`,
`scenes/player/Player.tscn`,
`scenes/ui/{DialogueBox,HUD,InventoryPanel,CauldronCraftingPanel}.tscn`.

## Art pipeline & conventions (IMPORTANT — learned the hard way)

PixelLab exports a folder per character: `animations/<long-name>/<dir>/frame_NNN.png`
(8 directions × ~9 walk frames) plus `rotations/<dir>.png` (8 idle poses). A Python
generator turns these into a `SpriteFrames` `.tres` with `walk_<dir>` / `idle_<dir>`
animations. Generators live in `tools/` (`build_marigold_spriteframes.py`,
`build_saffron_spriteframes.py`, `build_generic_customer_spriteframes.py`) — run the
matching generator to regenerate a `.tres` after re-export. Sage uses
`build_sage_spriteframes.py` for the same pipeline.
Marigold's active walking and idle art is the `with_staff` variant under
`art/characters/marigold/with_staff/`; the `default` and `no_hat` folders are inactive
outfit references and are not included in `Marigold.tres`.

Rules:
1. **New character standard (locked 2026-06-20):** Mapleton remains fully 2D,
   rectangular-grid, and non-isometric. Future and deliberately rebuilt humanoid
   characters use classic early-2000s fantasy MMORPG-inspired proportions and detail:
   native 96×112 frames, ordinary adults approximately 84-94 px tall, approximately
   3.1-3.6 heads tall, and `scale = 1.0`. This is a structural influence only; do not
   copy existing game characters, costumes, frames, palettes, or pixel clusters.
   Existing playable sprites remain unchanged until each one is intentionally rebuilt.
   See `docs/PIXEL_CHARACTER_GENERATION_WORKFLOW.md` for the production gates and
   `docs/CHARACTER_FACE_SYSTEM.md` for the native face construction rules. The current
   neutral south-eye standard uses a mirrored `3x3` role grid: `UUU / WPP / WPP`
   for the left eye and its horizontal mirror for the right. Complete reference sheets
   must be used to verify facing; static Ragnarok NPC examples are commonly south-west,
   not true south. Ordinary humanoids now use one exact shared face shape
   (`shared_south_v1`) rather than character-specific face families. Camellia's approved
   south sprite is `art/characters/npcs/camellia.png`; its preserved source is
   `concept_art/characters/camellia/south_source.png`. Her identity comes from auburn
   hair, palette, clothing, posture, and silhouette.
2. **Never overwrite/resample source art in place.** Baking a downscale into the PNGs
   (e.g. LANCZOS) blurs pixel art permanently. Instead, keep high-res frames and let
   Godot scale them at *display* time with the Nearest filter (crisp).
   - **Marigold:** 180px frames, `AnimatedSprite2D` `scale = 0.63`, offset `(0,-28)`.
   - **Saffron (cat):** 68px frames authored ~native, `scale = 1.0`, offset `(0,-17)`.
   - Rule of thumb: native-size art → scale 1.0; high-res art → display scale, never bake.
3. **Direction mapping lives in the `.tres`/generator, not in guesswork.** The generator
   maps each `walk_<dir>` animation to a source folder. Marigold currently uses the
   **identity** mapping (folder name = direction) because the art folders are correctly
   organised. If a character faces the wrong way, fix the folder→animation mapping in its
   generator — **trust the in-game observation over reading the frames.** (We lost time
   applying a wrong "mirror" remap; reverted to identity.)
4. **Feet/base at bottom-centre of the canvas**; set the sprite offset so the feet sit at
   the node origin. Y-sort uses node position, so this keeps depth + collision aligned.
5. Project setting `textures/canvas_textures/default_texture_filter = 0` (Nearest) — keep it.
6. **Before sending any paid/external art-generation API request, show the user the
   redacted request first and wait for explicit approval.** This especially applies to
   PixelLab Pro jobs, because they spend subscription credits. Include endpoint,
   method, estimated cost if known, dimensions, prompt/style fields, and which local
   reference images will be encoded. Never display or store API secrets; use
   `<base64 redacted>` / `<token redacted>` placeholders for request previews.

## Backups & safety

- `backups/` holds local art snapshots; it has a `.gdignore` (Godot skips it) and is
  git-ignored. See `backups/README.md`. Snapshots are taken before destructive art ops.
- **The repo is committed through 0.6** (latest implementation commit at handoff:
  `8cadb64`). Keep
  committing after each focused batch — it's the real safety net (an early loss of crisp
  Marigold frames predates the baseline). `.gitignore` excludes `.godot/`, `backups/`,
  and keeps `*.import` files. The implementation worktree was clean before this
  documentation-only handoff update.

## Next steps / backlog

- [ ] Vertical Slice 0.7 — Camellia's First Request and Quest Chaining v1.
      See `docs/plans/vertical_slice_0_7_camellia_quest_chaining.md`. Add one second
      request with quest prerequisites, one recipe unlock, one Camellia visitor, and
      register her with the existing closed-shop visitor rule. Do not add the village
      exterior, restaurant gameplay, relationships, schedules, new gathering regions,
      or a broad NPC system.
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
- [x] Sage PixelLab Pro sprite draft — `tools/generate_sage_pixellab_pro.py` submits
      a `create-character-pro` job with the Sage concept image plus a Mapleton style
      reference, then downloads the 8-direction export. Cleaned rotations live in
      `art/characters/npcs/sage/rotations/`; the shop scene uses the cleaned
      south-facing frame on the shared 180×180 sprite canvas. Earlier attempts are
      backed up in `backups/sage_sprite_iterations/`. Done 2026-06-17.
- [x] Initial git baseline exists; continue committing after focused art/system batches.
- [x] Cauldron & bed sprites (milestone 0.2a) — `art/props/shop/{cauldron,bed}.png`
      (native 72×56 / 72×44, scale 1.0) replace the `Polygon2D` "Visual" nodes in
      `ShopInterior.tscn`; zones/scripts/collision unchanged. Done 2026-06-16.
- [x] Forest gatherable sprites — `art/props/forest/{moonleaf_bush,forest_water_spring}.png`
      replace the reusable gatherable `Visual`; zones/scripts/collision unchanged.
      Done 2026-06-16.
- [x] Generic customer sprite — `art/characters/npcs/generic_customer.png` replaces the
      customer `Polygon2D`; sale request logic/collision unchanged. Done 2026-06-16.
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
