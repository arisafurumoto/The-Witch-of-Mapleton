#!/usr/bin/env python3
"""Separate a finished Mapleton 4x3 character sheet without altering its pixels."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


SHEET_SIZE = (200, 242)
CELL_SIZE = (50, 80)
COLUMNS = ("south", "west", "east", "north")
ROWS = (
    ("rotations", None),
    ("animations/walking", "frame_000.png"),
    ("animations/walking", "frame_001.png"),
)


def output_path(output_dir: Path, row: int, direction: str) -> Path:
    folder, frame_name = ROWS[row]
    if frame_name is None:
        return output_dir / folder / f"{direction}.png"
    return output_dir / folder / direction / frame_name


def separate(sheet_path: Path, output_dir: Path, force: bool) -> list[Path]:
    with Image.open(sheet_path) as source:
        sheet = source.convert("RGBA")

    if sheet.size != SHEET_SIZE:
        raise SystemExit(
            f"Expected a {SHEET_SIZE[0]}x{SHEET_SIZE[1]} sheet, got "
            f"{sheet.width}x{sheet.height}: {sheet_path}"
        )

    trailing_alpha = sheet.getchannel("A").crop((0, 240, 200, 242))
    if trailing_alpha.getbbox() is not None:
        raise SystemExit("The final two sheet rows must be fully transparent")

    targets = [
        output_path(output_dir, row, direction)
        for row in range(len(ROWS))
        for direction in COLUMNS
    ]
    existing = [path for path in targets if path.exists()]
    if existing and not force:
        raise SystemExit(
            f"Refusing to overwrite {len(existing)} existing frame(s); use --force"
        )

    written: list[Path] = []
    for row in range(len(ROWS)):
        for column, direction in enumerate(COLUMNS):
            box = (
                column * CELL_SIZE[0],
                row * CELL_SIZE[1],
                (column + 1) * CELL_SIZE[0],
                (row + 1) * CELL_SIZE[1],
            )
            frame = sheet.crop(box)
            target = output_path(output_dir, row, direction)
            target.parent.mkdir(parents=True, exist_ok=True)
            frame.save(target)

            with Image.open(target) as saved:
                if list(saved.convert("RGBA").getdata()) != list(frame.getdata()):
                    raise SystemExit(f"Pixel verification failed: {target}")
            written.append(target)

    return written


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("sheet", type=Path, help="Finished 200x242 PNG sheet")
    parser.add_argument("output_dir", type=Path, help="Character art output directory")
    parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite only the twelve frame files produced by this tool",
    )
    args = parser.parse_args()

    written = separate(args.sheet, args.output_dir, args.force)
    print(f"Wrote {len(written)} unchanged 50x80 frames to {args.output_dir}")


if __name__ == "__main__":
    main()
