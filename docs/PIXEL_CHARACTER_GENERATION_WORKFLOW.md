# Pixel Character Generation Workflow

This is the production workflow for Mapleton humanoid sprites. It starts from an
original Mapleton base template and uses Ragnarok Online only as a structural
study reference for proportions, facial grammar, rendering density, and the way
directional sprites are organised.

Mapleton must not copy Ragnarok characters, costumes, frames, palettes, poses, or
pixel clusters. Reference sheets are used temporarily for analysis and are not
stored in the project.

## Locked Style Split

Take from the structural reference:

```text
Large head and hair mass relative to the body
Compact torso and limbs
Small simplified hands and feet
Readable layered outfit silhouettes
Strong upper eye line with economical facial pixels
Dense clustered shading at a small native scale
Direction sets designed from one approved character model
```

Retain from Mapleton:

```text
Warm autumn palette
Softer dark-brown outlines
Cosy practical clothing
Less saturated shading
Each character's concept, age, identity, and silhouette
Fully 2D, rectangular-grid, non-isometric world art
```

## Reference Authority

Use references in this order:

1. Approved Mapleton base mannequin, head template, and palette.
2. The character's `concept.jpg` for identity, age, hair, clothing, and silhouette.
3. The character's written design notes.
4. Temporary Ragnarok reference sheets for structural checks only.
5. Existing `pixel_body.png` only when it clarifies how an outfit is assembled.

`pixel_body.png` has no authority over proportions, face style, rendering, palette,
canvas size, or pose. Rejected Mapleton generations must never be supplied as style
references to a new generation.

## Native Specification

The machine-readable values live in
`art/style_reference/character_standard.json`.

```text
Frame canvas:             96x112 px
Feet baseline:            y = 104
Ordinary adult height:    84-94 px
Ordinary adult width:     32-52 px
Body proportion:          3.1-3.6 heads tall
Head and hair mass:       approximately 28-34 percent of total height
Shared face rectangle:    12x8 px (`shared_south_v1`)
Gap between 3x3 eyes:     4 px
Display scale in Godot:   1.0
Visible colors:           32-48 per character
Alpha:                    binary only
```

The fixed canvas provides room for hair, hats, tools, and walk-cycle movement.
Visible dimensions describe the ordinary south-facing idle silhouette, not every
animation frame or exceptional character.

## Rendering Rules

```text
Outline: dark warm brown or hue-shifted local dark, never a uniform black halo
Light: top-left, consistent across every character and direction
Hair: 4-6 functional shades arranged in coherent locks and masses
Skin: 3-4 functional shades
Major cloth material: 3-5 functional shades
Small accent material: 2-3 functional shades
Isolated pixels: reserved for eyes, highlights, buttons, jewellery, or texture accents
Shadows: strongest beneath hair, chin, overlapping sleeves, belts, apron folds, and hems
```

Do not use smooth gradients, antialiasing, semitransparent edge pixels, pillow
shading, or thousands of near-duplicate colors. Shading must form deliberate pixel
clusters that describe planes, folds, curls, and overlapping materials.

## Phase 0: Build The Style Pack

Do this once before generating a named character:

1. Create an original neutral Mapleton humanoid south-facing mannequin.
2. Approve its height, head/body ratio, shoulder width, hands, feet, and baseline.
3. Create the single approved south-facing humanoid head and face template.
4. Create a Mapleton skin, outline, and neutral cloth palette reference.
5. Place the mannequin in a real 640x360 shop screenshot at scale 1.0.
6. Save approved files under `art/style_reference/characters/`.

Do not use Marigold, the generic customer, or a rejected Camellia draft as the base
mannequin. The style pack must be a fresh original construction.

## Phase 1: Generate One South-Facing Draft

Generate exactly one neutral south-facing idle pose.

Input roles:

```text
Mapleton mannequin: absolute proportion, perspective, and pixel-density authority
Mapleton head template: absolute facial scale and placement authority
Mapleton palette: outline, saturation, temperature, and shading authority
concept.jpg: character identity and costume authority
pixel_body.png: optional outfit-construction hint only
```

The built-in image generator may create a one-pose exploration on a removable
chroma background. Its high-resolution output is a generation source, not a final
sprite. PixelLab may be used for exact directional production after the south pose
is approved; every credit-consuming request must still be previewed and approved.

Never transform a rejected full-body sprite into a new style. Generate from the
approved style pack and concept inputs from scratch.

## Phase 2: Reconstruct At Native Scale

AI output is not accepted by downscaling alone.

1. Remove the chroma background without touching the source file.
2. Reconstruct the silhouette on the 96x112 native canvas.
3. Align the feet to y=104.
4. Reduce the palette to 48 or fewer intentional colors.
5. Rebuild the eyes, nose, and mouth directly on the native grid.
6. Repair outline thickness, clusters, hands, feet, and costume edges.
7. Keep only fully opaque or fully transparent pixels.
8. Save the cleaned sprite separately from the generation source.

Aseprite or Pixelorama is the preferred native-grid cleanup step. Automated
nearest-neighbour resizing may be used for a draft, but it cannot finish a sprite.

For a south-facing neutral template, define equal-sized eye rectangles in a face
metadata JSON file and validate their mirrored feature geometry. Color may differ
slightly across the face because of the top-left light; the dark eye construction
must not drift.

Define `face_rect` and `face_shape_id` in the same metadata. Ordinary humanoids must use
the exact `shared_south_v1` 12x8 face, four-pixel eye gap, one-pixel outer eye margins,
and approved jaw taper. Character identity may change hair and hairline, brows, color,
nose/mouth pixels, clothing, posture, and silhouette, but not the base face shape.

Use `art/style_reference/characters/mapleton_eye_templates.json` as the eye-shape
authority. Do not derive a south face from a diagonal reference. Complete Ragnarok
class/head sheets place true south first, followed by south-west, west, north-west,
north, north-east, east, and south-east; many static NPC sheets show south-west only.
Mapleton translates the true-south facial grammar into its own non-isometric view.
When face metadata supplies a template id, template path, and role colors,
`tools/validate_character_sprite.py` verifies the exact eye-role grid as well as
mirrored dark-feature geometry.

## Phase 3: Approval Gates

The south-facing sprite must pass all gates before more directions are made:

```text
[ ] Reads at native 1x scale
[ ] Reads at 3x output scale
[ ] Fits the approved mannequin proportion
[ ] Face remains readable when hair color is desaturated
[ ] Character remains identifiable when facial features are hidden
[ ] Palette and outline match Mapleton
[ ] Looks correct beside the environment at 640x360
[ ] Passes tools/validate_character_sprite.py
```

Validate with:

```bash
python3 tools/validate_character_sprite.py path/to/south.png
```

For a neutral template with face metadata:

```bash
python3 tools/validate_character_sprite.py path/to/south.png \
  --face-meta path/to/south.face.json
```

## Phase 4: Directions And Animation

1. Derive east, west, north, and diagonals from the approved south model.
2. Keep head size, shoulder width, baseline, palette, and light direction stable.
3. Approve all idle rotations as a single lineup.
4. Generate the walk only after the rotation lineup passes.
5. Use 8 directions and the existing generator-based `SpriteFrames` pipeline.
6. Inspect feet for sliding and head/hair for frame-to-frame volume changes.

Do not generate each direction independently from the concept sheet. That causes
proportion, face, palette, and costume drift.

## Prompt Skeleton

```text
Create one original south-facing idle sprite for The Witch of Mapleton.

Use the Mapleton mannequin as the absolute authority for proportions, pose,
perspective, feet baseline, and rendering density. Use the Mapleton head template
as the authority for face scale and feature placement. Use the Mapleton palette as
the authority for warm autumn color, soft dark-brown outlines, and restrained
saturation. Use the character concept only for identity, hair, age, costume, and
silhouette.

Render compact classic fantasy MMORPG sprite proportions, approximately 3.1-3.6
heads tall, with a large readable hair/head mass, compressed torso and limbs,
small hands and feet, layered clothing, and dense deliberate pixel clusters.

Do not copy any existing game character, costume, pose, frame, palette, or pixel
cluster. Do not use the style or proportions of an earlier rejected generation.
One character, one pose, no props unless required by the design, no text, no
shadow, and a removable flat chroma background.
```

## Definition Of Done

A character is not production-ready because an image generator returned a pleasing
picture. It is ready when the native south sprite passes validation, reads inside
the actual game, all rotations preserve one model, animation does not drift, and
the final `SpriteFrames` resource runs at scale 1.0 with feet on the node origin.
