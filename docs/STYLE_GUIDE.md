# STYLE_GUIDE.md

# The Witch of Mapleton - Visual Style Guide

## 1. Visual Target

**The Witch of Mapleton** uses a modern top-down 3/4 pixel-art style inspired by games such as Chef RPG.

The game is not isometric. It uses conventional 2D movement and collision, but buildings, furniture, trees, cliffs, shop interiors, and characters are drawn from a classic 3/4 viewing angle so their front faces and vertical volume are visible.

The goal is:

> Dense, cosy, magical, handcrafted, readable, and atmospheric.

The world should feel richly illustrated, but the player must always understand:

* Where they can walk
* What they can interact with
* What can be gathered
* Where doors and exits are
* Where the shop counter and crafting stations are
* Which NPCs are important

## 2. Visual References

Primary visual direction:

* Modern top-down 3/4 pixel art
* Detailed cosy interiors
* Dense environmental dressing
* Soft atmospheric lighting
* Readable character silhouettes
* Rich village and nature scenes
* Non-isometric world layout

Chef RPG is a reference for camera angle, density, modern pixel rendering, and environmental richness. The game should not directly copy Chef RPG assets, characters, UI, screenshots, palettes, or exact composition.

Safe reference wording:

```text
Modern top-down 3/4 pixel art, dense cosy environments, detailed props, dynamic lighting, non-isometric, handcrafted village atmosphere.
```

Avoid prompt wording like:

```text
Copy Chef RPG exactly.
Make this identical to Chef RPG.
Use a Chef RPG screenshot as the direct production reference.
```

## 3. Art Pipeline

The official art pipeline is:

```text
1. ChatGPT creates broad concept art or art-direction prompts.
2. PixelLab generates production-oriented pixel assets.
3. Aseprite or Pixelorama is used for cleanup.
4. Assets are imported into Godot.
5. Assets are tested at real game scale.
6. Approved assets are added to the style bible.
```

PixelLab is the main pixel-art generation tool.

PixelLab should be used for:

* Character sprites
* NPC sprites
* Black cat sprites
* Item icons
* Prop sheets
* Basic sprite animations
* Tileset drafts
* UI elements
* Style-consistent variations
* Reference-based asset generation

ChatGPT image generation should be used for:

* Concept art
* Mood exploration
* Shop exterior concepts
* Region concepts
* Title screen concepts
* Character direction
* Colour palette exploration
* Marketing-style art

Aseprite or Pixelorama should be used for:

* Final sprite cleanup
* Palette correction
* Animation timing
* Frame alignment
* Pixel-level edits
* Removing AI artefacts
* Sprite sheet organisation
* Exporting final production PNGs

## 4. Technical Art Specs

Recommended production specs:

```text
Base tile size: 16×16 px
Primary environment modules: 16×16 px and 32×32 px
Character sprite size: 32×48 px
Large NPC sprite maximum: 32×64 px
Black cat sprite: approximately 24×24 px or 24×32 px
Item icons: 16×16 px
Large item icons: 32×32 px
Dialogue portraits: 128×128 px
Internal resolution: 640×360
Output scale: 3× for 1920×1080
```

Default recommendation:

```text
Use 16×16 tiles, 32×48 characters, 128×128 portraits, and 640×360 internal resolution.
```

## 5. Camera and Perspective

The game uses a top-down 3/4 view.

Rules:

* The player sees the front face of buildings.
* Interior walls have visible height.
* Furniture has visible front faces.
* Tall objects can overlap the player.
* The player can walk behind selected objects.
* Collision should be much smaller than the visual sprite for tall objects.
* The game should not use diamond-grid isometric movement.

Examples:

A tree may have:

```text
Visual height: 80 px
Collision height: 16 to 24 px around the trunk base
Sorting origin: bottom centre
```

A shop counter may have:

```text
Visual height: 32 to 48 px
Collision: solid counter base
Interaction zone: front edge only
Sorting origin: bottom centre
```

## 6. Colour Direction

The game should use:

* Purple hues
* Warm sunset tones
* Soft amber lighting
* Autumn oranges and browns
* Deep forest greens
* Muted moss colours
* Dark timber
* Cream parchment tones
* Soft magical blues
* Subtle moonlight silver
* Lantern gold
* Misty greys

The world should not look:

* Neon
* Cyberpunk
* Overly saturated
* Plastic
* Harshly outlined
* Flat and empty
* Generic fantasy mobile-game style

## 7. Mood Keywords

Use these keywords consistently in prompts:

```text
cosy
witchy
warm
magical
gentle mystery
overgrown
autumnal
lantern-lit
handcrafted
dense environment
soft fog
detailed props
top-down 3/4
non-isometric
modern pixel art
readable gameplay silhouettes
```

Avoid these keywords unless specifically needed:

```text
isometric
hyper-detailed
realistic
HD painting
mobile game
anime chibi
neon
cyber
low-poly
smooth vector
```

## 8. Main Character Style

Main character:

```text
Name: Marigold
Role: young witch and shop owner
Hair: wavy purple shoulder-length hair
Outfit: dark, simple, practical witch outfit
Silhouette: readable at 32×48 px
Personality in sprite: curious, gentle, capable, slightly mysterious
```

Marigold should not look like:

* A glamorous fantasy sorceress
* A battle mage
* A school uniform witch
* A Halloween costume witch
* A generic anime protagonist

She should feel like a practical village witch who actually runs a shop, gathers ingredients, and talks to customers.

## 9. Black Cat Mascot Style

The black cat is a major visual and emotional anchor.

Sprite requirements:

```text
Small black cat companion
Readable silhouette
Expressive tail
Slight warm rim light or collar charm
Clear idle pose
Clear walk pose
Clear sit pose
Clear sleep pose
```

The cat should feel:

* Loyal
* Slightly smug
* Observant
* Magical but understated
* Funny without being cartoonish

Avoid making the cat:

* Too realistic
* Too big
* Too detailed
* Too humanoid
* Too much like a tutorial mascot

## 10. Environment Style

The environment should feel dense but readable.

Use TileMaps for:

* Grass
* Dirt paths
* Floors
* Water edges
* Interior walls
* Basic structural layout
* Cliffs
* Fences
* Ground transitions

Use individual sprites for:

* Lanterns
* Signs
* Shop props
* Books
* Cauldrons
* Dried herbs
* Mushrooms
* Ingredient plants
* Pots
* Crates
* Rugs
* Baskets
* Vines
* Windows
* Benches
* Magical objects

The world should not look grid-stamped. Tile repetition should be broken with hand-placed decorative sprites.

## 11. Lighting and Atmosphere

Lighting should support the art, not replace it.

Use:

* Hand-painted shadows first
* Subtle dynamic lights second
* Particles third
* Shaders only where useful

Recommended dynamic light uses:

* Lanterns
* Shop windows
* Cauldron glow
* Moonlit forest clearings
* Magic ingredients
* Fireflies
* Shrine lights
* Festival decorations

Avoid:

* Excessive bloom
* Too many lights
* Lighting that destroys pixel readability
* Smooth gradients that clash with pixel art
* Heavy shader effects before the base art works

## 12. Godot Layering Model

Recommended scene layering:

```text
TileMapLayer_Ground
TileMapLayer_Path
TileMapLayer_Low_Details
TileMapLayer_Collision
Node2D_YSort_Characters_And_Props
Node2D_Foreground_Overlays
CanvasModulate_Global_Tint
PointLight2D_And_Other_Lights
GPUParticles2D_Atmosphere
CanvasLayer_UI
```

Y-sort should be used for:

* Player
* NPCs
* Cat
* Trees
* Counters
* Tall furniture
* Signs
* Large props

## 13. PixelLab Prompt Template

Use this structure for PixelLab prompts:

```text
[asset type], modern top-down 3/4 pixel art, non-isometric, cosy witch village game, detailed but readable, warm purple and autumn palette, lantern-lit magical atmosphere, clear silhouette, transparent background, game-ready sprite, consistent with The Witch of Mapleton style.
```

Example Marigold prompt:

```text
32×48 px character sprite, modern top-down 3/4 pixel art, non-isometric, young village witch named Marigold, wavy shoulder-length purple hair, dark simple practical witch outfit, soft gothic cottage-witch feeling, readable silhouette, cosy magical village game, transparent background.
```

Example black cat prompt:

```text
Small black cat companion sprite, modern top-down 3/4 pixel art, non-isometric, cosy witch village game, expressive tail, tiny warm magical collar charm, readable silhouette, transparent background, game-ready sprite.
```

Example shop prop prompt:

```text
Pixel art prop sheet for a cosy witch shop, modern top-down 3/4 non-isometric style, includes cauldron, potion bottles, dried herbs, candle lantern, wooden counter, small spellbook, moonleaf basket, warm purple autumn palette, transparent background.
```

## 14. Asset Approval Checklist

Before an asset is approved, check:

* Does it read clearly at game scale?
* Does it match the palette?
* Does it match the perspective?
* Is the silhouette clear?
* Does it have too much detail?
* Does it look good beside Marigold?
* Does it look good beside the tileset?
* Is the transparent background clean?
* Are there stray pixels?
* Is the sprite origin correct?
* Is the collision area obvious?
* Does the animation jitter?
* Can it be reused?

An asset is not approved until it has been tested inside Godot.

## 15. Initial Asset Priorities

Create assets in this order:

1. Marigold front idle
2. Marigold 4-direction idle
3. Marigold 4-direction walk
4. Black cat idle
5. Black cat walk
6. Shop floor and wall tiles
7. Shop counter
8. Crafting table or cauldron
9. Bed
10. Door
11. Moonleaf bush
12. Forest water spring
13. Grass and dirt path tiles
14. Calming Tea icon
15. Moonleaf icon
16. Dialogue box UI
17. Inventory UI panel

Do not produce dozens of NPCs before the first playable loop works.
