# AI_WORKFLOW.md

# The Witch of Mapleton - AI Workflow

## 1. AI Roles

This project is being developed with heavy AI assistance.

The official tool roles are:

```text
ChatGPT: design, planning, documentation, art direction, prompts, architecture review, debugging explanation
Claude Code: Godot implementation, file edits, refactoring, local project work
PixelLab: production-oriented pixel asset drafts
Aseprite or Pixelorama: final pixel cleanup and animation correction
Godot: implementation, scene testing, gameplay validation
```

## 2. Core Rule

AI should accelerate production, not expand the game uncontrollably.

Default rule:

```text
Build the smallest working version of one system at a time.
```

Avoid:

```text
Large rewrites
Premature architecture
Unrequested features
Bulk content generation
Complicated inheritance
Hidden magic logic
Implementing future systems too early
```

## 3. Phase 1 Completion Checklist

Phase 1 is complete when these files exist:

```text
docs/GDD.md
docs/STYLE_GUIDE.md
docs/DATA_SCHEMA.md
docs/AI_WORKFLOW.md
CLAUDE.md
data/items.json
data/recipes.json
data/npcs.json
data/shop_requests.json
data/dialogue/camellia.json
data/dialogue/customer_generic.json
data/dialogue/cat.json
```

And the project has this structure:

```text
scenes/player/
scenes/world/
scenes/shop/
scenes/ui/
scenes/npc/
scenes/systems/
scripts/core/
scripts/systems/
scripts/ui/
scripts/npc/
art/characters/
art/tilesets/
art/ui/
art/items/
art/concepts/
audio/sfx/
audio/music/
```

## 4. Milestone 0

Milestone 0 is the foundation milestone.

Deliverables:

```text
Godot project created
Git repository created
Folder structure created
Project docs added
Initial JSON data files added
CLAUDE.md added
No gameplay implementation yet
```

Milestone 0 should not include:

```text
Player movement
Inventory UI
Shop logic
Dialogue UI
Save/load
Art production beyond placeholders
```

## 5. Vertical Slice 0.1

Vertical Slice 0.1 is called:

```text
First Potion Sale
```

Required player flow:

```text
1. Start inside Marigold's witch shop.
2. Move around.
3. Black cat follows the player.
4. Exit to a small forest clearing.
5. Gather Moonleaf.
6. Gather Forest Water.
7. Return to the shop.
8. Craft Calming Tea.
9. Customer enters.
10. Customer asks for Calming Tea.
11. Sell Calming Tea.
12. Receive gold.
13. Sleep.
14. Save game.
15. Start new day.
```

This is the first true goal.

## 6. Claude Code Usage Pattern

Use Claude Code for implementation only after the design target is clear.

Each Claude Code prompt should include:

```text
Context
Goal
Requirements
Non-goals
Expected files
Testing instructions
Summary request
```

Good prompt structure:

```text
Context:
This is a Godot 4.6 GDScript cosy witch shop game.

Goal:
Implement the smallest working version of [system].

Requirements:
- Requirement 1
- Requirement 2
- Requirement 3

Non-goals:
- Do not add unrelated features.
- Do not implement future systems.
- Do not rewrite unrelated files.

Testing:
Explain how I can test this in Godot.

After implementation:
List changed files and summarise the behaviour.
```

## 7. First Claude Code Prompt

Use this prompt for Milestone 0:

```text
Set up the initial project structure for a Godot 4.6 GDScript pixel-art cosy witch game called The Witch of Mapleton.

Create these folders:

docs/
data/
data/dialogue/
scenes/player/
scenes/world/
scenes/shop/
scenes/ui/
scenes/npc/
scenes/systems/
scripts/core/
scripts/systems/
scripts/ui/
scripts/npc/
art/characters/
art/characters/marigold/
art/characters/cat/
art/characters/npcs/
art/characters/portraits/
art/tilesets/
art/ui/
art/items/
art/concepts/
audio/sfx/
audio/music/

Create placeholder files:

docs/GDD.md
docs/STYLE_GUIDE.md
docs/DATA_SCHEMA.md
docs/AI_WORKFLOW.md
data/items.json
data/recipes.json
data/npcs.json
data/shop_requests.json
data/dialogue/camellia.json
data/dialogue/customer_generic.json
data/dialogue/cat.json
CLAUDE.md

Do not implement gameplay yet.

After creating the files:
- Summarise the folder structure.
- Confirm no gameplay was implemented.
- Recommend the next smallest implementation step.
```

## 8. CLAUDE.md Content

Create a file at the project root called:

```text
CLAUDE.md
```

Use this content:

```md
# The Witch of Mapleton - Claude Code Instructions

This is a Godot 4.6 GDScript project.

The game is a cosy top-down 3/4 pixel-art witch life sim about Marigold, a young witch with long wavy copper-orange hair and a cosy autumn village-witch outfit, who runs a magical shop in the village of Mapleton with her black cat companion.

## Development Rules

- Build one system at a time.
- Keep code simple and readable.
- Prefer GDScript.
- Prefer data-driven systems using JSON.
- Do not add features that were not requested.
- Do not implement future systems early.
- Avoid large rewrites.
- Avoid clever abstractions.
- Use placeholder art until the gameplay loop works.
- After changes, list changed files.
- Explain how to test changes in Godot.

## Visual Direction

The game uses modern top-down 3/4 pixel art inspired by Chef RPG.

It is not isometric. It uses conventional 2D movement and collision, but objects are drawn with visible front faces and vertical depth.

The art direction is cosy, witchy, warm, magical, dense, handcrafted, autumnal, lantern-lit, and readable.

PixelLab is used for production-oriented pixel asset drafts. Aseprite or Pixelorama is used for cleanup.

## Current Target

The first playable vertical slice is called First Potion Sale.

The required flow is:
1. Start in the witch shop.
2. Move around.
3. Black cat follows the player.
4. Exit to a small forest clearing.
5. Gather Moonleaf and Forest Water.
6. Return to shop.
7. Craft Calming Tea.
8. Sell it to a customer.
9. Receive gold.
10. Sleep.
11. Save.
12. Start the next day.

Do not build beyond this target unless explicitly asked.

## Data Files

Use:
- data/items.json
- data/recipes.json
- data/npcs.json
- data/shop_requests.json
- data/dialogue/

Do not hard-code item names, recipe ingredients, NPC dialogue, or shop requests unless explicitly temporary.
```

## 9. PixelLab Workflow

PixelLab is the main asset draft generator.

Use PixelLab after the gameplay placeholder version exists, not before.

Asset order:

```text
1. Marigold idle
2. Marigold 4-direction walk
3. Black cat idle
4. Black cat walk
5. Moonleaf bush
6. Forest water spring
7. Shop floor and wall tiles
8. Shop counter
9. Cauldron or crafting station
10. Calming Tea icon
11. Dialogue box UI
```

Do not generate all romance candidates, town areas, or ancient-region assets before the vertical slice works.

## 10. PixelLab Approval Process

Every PixelLab asset must pass this checklist:

```text
Looks good at 100 percent pixel scale
Reads clearly in Godot
Matches the 3/4 top-down perspective
Has a clean transparent background
Uses the approved palette direction
Does not look too noisy
Has a correct sprite origin
Does not jitter during animation
Works beside Marigold
Works beside the tileset
```

If the asset fails, either regenerate or clean it in Aseprite or Pixelorama.

## 11. ChatGPT Usage

Use ChatGPT for:

```text
Breaking the game into milestones
Designing systems before implementation
Writing Claude Code prompts
Reviewing Claude Code output
Creating PixelLab prompts
Developing NPCs and dialogue
Keeping scope controlled
Debugging explanations
Writing documentation
```

Good ChatGPT prompt:

```text
I am building The Witch of Mapleton in Godot 4.6. The next system is inventory. Design the simplest data-driven inventory system for the First Potion Sale vertical slice. Include the scene/script structure, JSON data needed, and a Claude Code implementation prompt. Do not add equipment, storage, item quality, or sorting yet.
```

## 12. PixelLab Prompt Pattern

Use this format:

```text
[asset type], modern top-down 3/4 pixel art, non-isometric, cosy witch village game, detailed but readable, warm purple and autumn palette, lantern-lit magical atmosphere, clear silhouette, transparent background, game-ready sprite, consistent with The Witch of Mapleton style.
```

Example:

```text
32×48 px character sprite, modern top-down 3/4 pixel art, non-isometric, young village witch named Marigold, long wavy copper-orange hair, soft golden-brown eyes, wide olive witch hat with autumn flowers, moss-green layered dress, cream puff sleeves, rust-orange shawl, brown lace-up boots, twisted wooden staff with warm amber crystal, cosy autumn cottage-witch feeling, readable silhouette, cosy magical village game, transparent background.
```

## 13. Implementation Order After Phase 1

After Phase 1, build in this order:

```text
1. Player movement
2. Camera follow
3. Collision
4. Interaction system
5. Basic scene transition between shop and forest
6. Item database loader
7. Inventory system
8. Gatherable nodes
9. Crafting system
10. Shop sale system
11. Dialogue box
12. Black cat companion follow
13. Save/load
14. Day advancement
```

Do not reorder unless there is a strong technical reason.

## 14. Definition of Done For Each System

A system is done when:

```text
It works in Godot
It can be tested manually
It does not require unrelated future systems
It uses simple readable code
It has no obvious hard-coded content that should be data
The changed files are known
The next smallest step is clear
```

## 15. Main Risk

The main risk is not code. The main risk is uncontrolled scope.

The project must avoid generating:

```text
Too many characters
Too many areas
Too many systems
Too many art styles
Too many recipes
Too many quests
Too many future mechanics
```

The correct strategy is:

```text
Make one beautiful, tiny, working loop first.
```
