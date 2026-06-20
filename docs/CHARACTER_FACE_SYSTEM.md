# Character Face System

This document defines Mapleton's Ragnarok-structure-inspired facial grammar. It
does not reproduce Ragnarok faces or pixels. The goal is to use similarly
economical, readable construction while retaining Mapleton's softer outlines,
warm palette, restrained saturation, and original character concepts.

Read `docs/PIXEL_CHARACTER_GENERATION_WORKFLOW.md` first.

## Core Principle

The head and hair mass carries most identity. Facial pixels communicate expression,
age, and temperament, but they do not contain portrait-level detail.

Build the face directly at native scale. A high-resolution generated face cannot
become production art through automatic downscaling.

## Native South-Facing Budget

```text
Character height:       84-94 px
Head and hair mass:     approximately 26-32 px tall
Shared face rectangle:  12 px wide x 8 px tall
Eye cluster:            3 px wide x 3 px tall per eye
Space between eyes:     4 px
Nose:                   0-2 px
Mouth:                  1-3 px
```

Hair, ears, hats, and accessories may extend beyond the ordinary head mass. Every
ordinary humanoid uses the same `shared_south_v1` face shape. Hair is built around
that skull and face; the face is never narrowed or reshaped to fit the hairstyle.

## Facial Grammar

### Eyes

* Use a strong dark upper line.
* Use a compact `2x2` pupil beneath a strong three-pixel upper lid.
* Keep the white of each eye to a two-pixel outer column. Do not surround the pupil
  with white or turn the eye into a circular eye box.
* Keep the neutral south-eye geometry identical across ordinary humanoids.
* Keep both eyes on a shared perspective line in the south pose.
* Neutral south-facing templates must use mirror-consistent dark eye geometry.
  Lighting colors may vary; feature placement may not.
* Use brows and the mouth for character expression instead of changing the base eye shape.
* Avoid giant circular anime eyes, smooth gradients, and scattered-pixel eyelashes.

The neutral Mapleton south-eye template uses a `3x3` role grid per eye. The right eye
is the horizontal mirror of the left:

```text
Left eye       Right eye
U U U          U U U
W P P          P P W
W P P          P P W

U = dark upper lid
P = darkest pupil
W = white part of eye
```

This is an original Mapleton reconstruction of the economical true-south facial
grammar observed across multiple early fantasy MMORPG head sheets. It is not a copied
pixel cluster. Ordinary humanoids reuse this geometry exactly in the neutral south pose.

### Brows

Brows may be separate, merged visually with the upper eye line, or partly hidden by
hair. Use them only when they remain readable at native scale. Brow angle should
support personality without turning into a permanently exaggerated expression.

### Nose

Use no more than two pixels: usually one warm shadow or highlight. The nose must
never become a miniature outlined shape.

### Mouth

Use one to three pixels. Mouth shape is more important than lip color. Reserve
larger mouth clusters for dialogue portraits, not gameplay sprites.

### Age

Age comes from hairline, hairstyle, brows, mouth, posture, palette, and clothing rather
than a different face shape. Add at most one or two deliberate age-shadow pixels. Do
not create wrinkle texture.

## Shared Humanoid Face

All ordinary humanoids use one native south-facing shape:

```text
Template id:        shared_south_v1
Face rectangle:     12x8 px
Row widths:         10, 12, 12, 12, 10, 10, 8, 6 px
Left eye offset:    x=1, y=1
Right eye offset:   x=8, y=1
Eye gap:            4 px
Outer eye margins:  1 px
```

The face shape, jaw taper, eye placement, and neutral eye geometry do not vary by
character. Identity comes from hair and hairline, brows, eye color, nose/mouth pixels,
skin palette, clothing, accessories, posture, and silhouette. Children, non-human
characters, and exceptional body types require a separately approved standard rather
than a new named-character face family.

## Direction Rules

Ragnarok reference sheets must be direction-checked before study. In the complete
class and modular-head sheets reviewed for this standard, the first eight direction
slots are:

```text
South, south-west, west, north-west, north, north-east, east, south-east
```

Static NPC sheets often show only a south-west pose. That diagonal pose is not a
straight-south face authority: its far eye is narrower and its features are shifted.
Mapleton remains non-isometric; only the facial economy is adapted.

```text
South:      Full approved face construction
Diagonal:   Far eye narrows by one pixel; nose shifts toward the near side
East/west:  One visible eye and upper line; nose becomes part of the silhouette
North:      No face; identity comes from head, hair, ears, hat, and accessories
```

Directions are derived from the approved south face. Never independently ask a
generator to reinterpret the face for each direction.

## Approval Tests

```text
[ ] Face is built on the native 96x112 frame
[ ] Eye geometry reads at 1x and 3x
[ ] Face uses `shared_south_v1`: 12x8 px with a 4 px eye gap
[ ] Shared face remains unchanged with hair temporarily hidden
[ ] Character remains identifiable with facial pixels temporarily hidden
[ ] Face uses binary alpha and deliberate color clusters
[ ] Nose uses no more than two pixels
[ ] Mouth uses no more than three pixels
[ ] Age is communicated without scattered wrinkle pixels
[ ] Face is approved before rotations or animation begin
```
