# Character Sheet References

This directory contains the optional Mapleton palette reference:

```text
mapleton_palette.png  Shared palette reference for manual Retro Diffusion work
```

Character image creation is user-managed outside the repo. Follow
`docs/CHARACTER_SPRITE_SHEET_WORKFLOW.md` after a finished sheet is supplied.

The canonical structural source sheet lives outside runtime art at:

```text
concept_art/style_reference/thin_humanoid_4dir_walk.png
```

It is a 200x242 sheet using 50x80 cells, four direction columns
(`south`, `west`, `east`, `north`), and three animation rows (`idle`, `walk_a`,
`walk_b`). The final two rows are transparent padding. Finished character sheets use
that layout and are separated losslessly; no mannequin, head template, or face metadata
is part of the pipeline.
