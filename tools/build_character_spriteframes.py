#!/usr/bin/env python3
"""Package existing separated character frames into a Godot SpriteFrames resource.

This tool does not create, crop, resize, repaint, or otherwise modify PNG files.
It only validates the expected runtime frame folders and writes a `.tres` file.
"""

from __future__ import annotations

import argparse
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DIRECTIONS = (
    ("east", "east"),
    ("south-east", "south_east"),
    ("south", "south"),
    ("south-west", "south_west"),
    ("west", "west"),
    ("north-west", "north_west"),
    ("north", "north"),
    ("north-east", "north_east"),
)


def resource_path(path: Path) -> str:
    try:
        relative = path.resolve().relative_to(ROOT)
    except ValueError as exc:
        raise SystemExit(f"Path must be inside the project: {path}") from exc
    return f"res://{relative.as_posix()}"


def walk_root(character_dir: Path) -> Path:
    animations_dir = character_dir / "animations"
    if animations_dir.is_dir():
        for child in animations_dir.iterdir():
            if child.is_dir() and child.name in ("walking", "Walking"):
                return child
    raise SystemExit(
        "Missing walk animation folder: expected animations/walking or animations/Walking "
        f"under {character_dir}"
    )


def build(
    character_dir: Path,
    output: Path,
    walk_frame_count: int,
    walk_speed: float,
    idle_speed: float,
) -> None:
    character_dir = character_dir.resolve()
    output = output.resolve()
    idle_dir = character_dir / "rotations"
    walking_dir = walk_root(character_dir)

    ext_lines: list[str] = []
    ext_ids: dict[Path, str] = {}

    def ext_id(path: Path) -> str:
        path = path.resolve()
        if not path.exists():
            raise SystemExit(f"Missing character frame: {path}")
        if path not in ext_ids:
            identifier = f"t{len(ext_ids) + 1}"
            ext_ids[path] = identifier
            ext_lines.append(
                f'[ext_resource type="Texture2D" path="{resource_path(path)}" '
                f'id="{identifier}"]'
            )
        return ext_ids[path]

    animations: list[str] = []
    for folder, suffix in DIRECTIONS:
        frames: list[str] = []
        for index in range(walk_frame_count):
            frame_path = walking_dir / folder / f"frame_{index:03d}.png"
            identifier = ext_id(frame_path)
            frames.append(
                '{\n"duration": 1.0,\n"texture": ExtResource("%s")\n}' % identifier
            )
        animations.append(
            '{\n"frames": [%s],\n"loop": true,\n"name": &"walk_%s",\n"speed": %s\n}'
            % (", ".join(frames), suffix, walk_speed)
        )

    for folder, suffix in DIRECTIONS:
        frame_path = idle_dir / f"{folder}.png"
        identifier = ext_id(frame_path)
        frame = '{\n"duration": 1.0,\n"texture": ExtResource("%s")\n}' % identifier
        animations.append(
            '{\n"frames": [%s],\n"loop": true,\n"name": &"idle_%s",\n"speed": %s\n}'
            % (frame, suffix, idle_speed)
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
    print(
        f"Wrote {output} | textures: {len(ext_ids)} | "
        f"animations: {len(animations)} | load_steps: {len(ext_ids) + 1}"
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("character_dir", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--walk-frame-count", type=int, default=6)
    parser.add_argument("--walk-speed", type=float, default=12.0)
    parser.add_argument("--idle-speed", type=float, default=4.0)
    args = parser.parse_args()
    build(
        args.character_dir,
        args.output,
        args.walk_frame_count,
        args.walk_speed,
        args.idle_speed,
    )


if __name__ == "__main__":
    main()
