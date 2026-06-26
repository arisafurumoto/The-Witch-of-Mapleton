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


def build(character_dir: Path, output: Path, walk_frame_count: int = 2) -> None:
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
        walk_dir = (
            character_dir
            / "animations"
            / "walking"
            / source_direction
        )
        walk_frames = [
            walk_dir / f"frame_{index:03d}.png"
            for index in range(walk_frame_count)
        ]
        if walk_frame_count == 2:
            frame_ids = [
                ext_id(walk_frames[0]),
                ext_id(idle),
                ext_id(walk_frames[1]),
                ext_id(idle),
            ]
        else:
            frame_ids = [ext_id(frame) for frame in walk_frames]
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
    parser.add_argument(
        "--walk-frame-count",
        type=int,
        choices=(2, 4),
        default=2,
        help="Number of authored walk frames per direction (default: 2)",
    )
    args = parser.parse_args()
    build(args.character_dir, args.output, args.walk_frame_count)


if __name__ == "__main__":
    main()
