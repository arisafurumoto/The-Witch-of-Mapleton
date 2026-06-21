#!/usr/bin/env python3
"""Build Godot SpriteFrames from a separated four-direction character sheet."""

from __future__ import annotations

import argparse
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WALK_SPEED = 8.0
IDLE_SPEED = 4.0

# Existing movement code requests eight animation names. Diagonals reuse the nearest
# side-facing art; no image files are duplicated or modified.
DIRECTIONS = (
    ("east", "east"),
    ("east", "south_east"),
    ("south", "south"),
    ("west", "south_west"),
    ("west", "west"),
    ("west", "north_west"),
    ("north", "north"),
    ("east", "north_east"),
)


def resource_path(path: Path) -> str:
    try:
        relative = path.resolve().relative_to(ROOT)
    except ValueError as exc:
        raise SystemExit(f"Path must be inside the project: {path}") from exc
    return f"res://{relative.as_posix()}"


def build(character_dir: Path, output: Path) -> None:
    ext_lines: list[str] = []
    ext_ids: dict[Path, str] = {}

    def ext_id(path: Path) -> str:
        if not path.exists():
            raise SystemExit(f"Missing separated frame: {path}")
        if path not in ext_ids:
            identifier = f"t{len(ext_ids) + 1}"
            ext_ids[path] = identifier
            ext_lines.append(
                f'[ext_resource type="Texture2D" path="{resource_path(path)}" '
                f'id="{identifier}"]'
            )
        return ext_ids[path]

    animations: list[str] = []
    for source_direction, animation_direction in DIRECTIONS:
        idle = character_dir / "rotations" / f"{source_direction}.png"
        walk_a = (
            character_dir
            / "animations"
            / "walking"
            / source_direction
            / "frame_000.png"
        )
        walk_b = walk_a.with_name("frame_001.png")
        frame_ids = [ext_id(walk_a), ext_id(idle), ext_id(walk_b), ext_id(idle)]
        frames = ", ".join(
            '{\n"duration": 1.0,\n"texture": ExtResource("%s")\n}' % identifier
            for identifier in frame_ids
        )
        animations.append(
            '{\n"frames": [%s],\n"loop": true,\n"name": &"walk_%s",'
            '\n"speed": %s\n}' % (frames, animation_direction, WALK_SPEED)
        )

    for source_direction, animation_direction in DIRECTIONS:
        idle = character_dir / "rotations" / f"{source_direction}.png"
        frame = (
            '{\n"duration": 1.0,\n"texture": ExtResource("%s")\n}'
            % ext_id(idle)
        )
        animations.append(
            '{\n"frames": [%s],\n"loop": true,\n"name": &"idle_%s",'
            '\n"speed": %s\n}' % (frame, animation_direction, IDLE_SPEED)
        )

    output.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        f'[gd_resource type="SpriteFrames" load_steps={len(ext_ids) + 1} format=3]',
        "",
        *ext_lines,
        "",
        "[resource]",
        "animations = [" + ", ".join(animations) + "]",
        "",
    ]
    output.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {output} with {len(animations)} animations and {len(ext_ids)} textures")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("character_dir", type=Path)
    parser.add_argument("output", type=Path, help="Output .tres path")
    args = parser.parse_args()
    build(args.character_dir, args.output)


if __name__ == "__main__":
    main()
