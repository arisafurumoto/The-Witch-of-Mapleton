# Character Sprite Sheet Workflow

The user creates each finished humanoid sheet manually in Retro Diffusion. The repo
does not generate character images, downscale them, rebuild faces, or repaint pixels.

## Input Contract

Use the same layout as Sage's approved sheet:

```text
Sheet size: 200x242 px
Cell size: 50x80 px
Columns: south, west, east, north
Rows: idle, walk frame A, walk frame B
Final two rows: fully transparent padding
Background: transparent
```

Keep the finished sheet unchanged under:

```text
concept_art/characters/<character_id>/<character_id>_4dir_walk.png
```

The thin layout reference is
`concept_art/style_reference/thin_humanoid_4dir_walk.png`. The optional palette
reference is `art/style_reference/characters/mapleton_palette.png`.

## Separate The Frames

Run:

```bash
python3 tools/separate_character_sheet.py \
  concept_art/characters/<character_id>/<character_id>_4dir_walk.png \
  art/characters/npcs/<character_id>
```

The tool writes:

```text
rotations/{south,west,east,north}.png
animations/walking/<direction>/frame_000.png
animations/walking/<direction>/frame_001.png
```

Each output is an exact 50x80 crop. The tool performs no resizing, padding,
repositioning, palette conversion, transparency cleanup, or face editing. It refuses
unexpected dimensions, non-transparent trailing rows, and existing output frames
unless `--force` is supplied.

## Import Checklist

1. Preserve the supplied sheet unchanged in `concept_art/`.
2. Snapshot current production art if existing frames will be replaced.
3. Run the separator.
4. Package the frames with:

   ```bash
   python3 tools/build_4dir_spriteframes.py \
     art/characters/npcs/<character_id> \
     art/characters/npcs/<character_id>/<CharacterName>.tres
   ```

   The required diagonal animation names reuse cardinal textures; no image files are
   duplicated or edited.

   Characters with four authored walking frames per direction use:

   ```bash
   python3 tools/build_4dir_spriteframes.py \
     <character_art_directory> \
     <spriteframes_output> \
     --walk-frame-count 4
   ```

   Marigold's active `with_staff` art uses this four-frame option.
5. Run Godot's headless import.
6. Check all four directions and both walk frames at game scale.
7. Adjust only the scene's display offset or direction mapping when required; do not
   rewrite the source pixels.

Existing characters with older frame sizes remain unchanged until deliberately
replaced by a finished sheet.
