#!/usr/bin/env python3
"""Validate a native Mapleton humanoid sprite against the locked art spec."""

import argparse
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SPEC = ROOT / "art" / "style_reference" / "character_standard.json"


def largest_component_fraction(alpha: Image.Image) -> float:
    width, height = alpha.size
    pixels = alpha.load()
    seen: set[tuple[int, int]] = set()
    component_sizes: list[int] = []
    visible_pixels = 0

    for y in range(height):
        for x in range(width):
            if pixels[x, y] == 0:
                continue
            visible_pixels += 1
            if (x, y) in seen:
                continue

            stack = [(x, y)]
            seen.add((x, y))
            component_size = 0
            while stack:
                current_x, current_y = stack.pop()
                component_size += 1
                for next_x in range(current_x - 1, current_x + 2):
                    for next_y in range(current_y - 1, current_y + 2):
                        if next_x < 0 or next_y < 0 or next_x >= width or next_y >= height:
                            continue
                        point = (next_x, next_y)
                        if point in seen or pixels[next_x, next_y] == 0:
                            continue
                        seen.add(point)
                        stack.append(point)
            component_sizes.append(component_size)

    if visible_pixels == 0:
        return 0.0
    return float(max(component_sizes, default=0)) / float(visible_pixels)


def validate_sprite(path: Path, spec: dict) -> list[str]:
    failures: list[str] = []
    image = Image.open(path).convert("RGBA")
    canvas = spec["canvas"]
    profile = spec["ordinary_adult"]
    rendering = spec["rendering"]

    expected_size = (canvas["width"], canvas["height"])
    if image.size != expected_size:
        failures.append(f"canvas is {image.size[0]}x{image.size[1]}, expected {expected_size[0]}x{expected_size[1]}")

    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        failures.append("sprite has no visible pixels")
        return failures

    visible_width = bbox[2] - bbox[0]
    visible_height = bbox[3] - bbox[1]
    if not profile["visible_width_min"] <= visible_width <= profile["visible_width_max"]:
        failures.append(
            f"visible width is {visible_width}, expected {profile['visible_width_min']}-{profile['visible_width_max']}"
        )
    if not profile["visible_height_min"] <= visible_height <= profile["visible_height_max"]:
        failures.append(
            f"visible height is {visible_height}, expected {profile['visible_height_min']}-{profile['visible_height_max']}"
        )
    if bbox[3] != canvas["feet_baseline_y"]:
        failures.append(f"feet end at y={bbox[3]}, expected baseline y={canvas['feet_baseline_y']}")

    colors = image.getcolors(maxcolors=image.width * image.height)
    if colors is None:
        failures.append("could not count sprite colors")
    else:
        visible_color_count = sum(1 for _count, color in colors if color[3] > 0)
        if visible_color_count > rendering["visible_color_max"]:
            failures.append(
                f"sprite uses {visible_color_count} visible colors, maximum is {rendering['visible_color_max']}"
            )
        if rendering["binary_alpha_required"]:
            partial_alpha_pixels = sum(count for count, color in colors if 0 < color[3] < 255)
            if partial_alpha_pixels > 0:
                failures.append(f"sprite has {partial_alpha_pixels} partially transparent pixels")

    component_fraction = largest_component_fraction(alpha)
    if component_fraction < rendering["main_component_min_fraction"]:
        failures.append(
            f"largest connected component contains {component_fraction:.1%} of visible pixels, "
            f"minimum is {rendering['main_component_min_fraction']:.0%}"
        )

    print(
        f"{path}: canvas={image.width}x{image.height} "
        f"visible={visible_width}x{visible_height} baseline={bbox[3]} "
        f"main_component={component_fraction:.1%}"
    )
    return failures


def validate_face_symmetry(image_path: Path, metadata_path: Path) -> list[str]:
    failures: list[str] = []
    image = Image.open(image_path).convert("RGBA")
    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    left_rect = metadata["left_eye_rect"]
    right_rect = metadata["right_eye_rect"]
    threshold = float(metadata["feature_luminance_max"])

    if left_rect[2:] != right_rect[2:]:
        return ["left and right eye rectangles have different sizes"]

    width, height = left_rect[2], left_rect[3]
    mismatches: list[tuple[int, int]] = []
    for y in range(height):
        for x in range(width):
            left = image.getpixel((left_rect[0] + x, left_rect[1] + y))
            right = image.getpixel((right_rect[0] + width - 1 - x, right_rect[1] + y))
            left_luminance = 0.2126 * left[0] + 0.7152 * left[1] + 0.0722 * left[2]
            right_luminance = 0.2126 * right[0] + 0.7152 * right[1] + 0.0722 * right[2]
            left_is_feature = left[3] > 0 and left_luminance <= threshold
            right_is_feature = right[3] > 0 and right_luminance <= threshold
            if left_is_feature != right_is_feature:
                mismatches.append((x, y))

    if mismatches:
        failures.append(f"mirrored eye feature masks differ at {mismatches}")
    else:
        print(
            f"{image_path}: eye geometry is mirror-consistent "
            f"({width}x{height} patches, luminance threshold {threshold:g})"
        )
    return failures


def validate_face_template(image_path: Path, metadata_path: Path) -> list[str]:
    image = Image.open(image_path).convert("RGBA")
    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    if "eye_template_path" not in metadata:
        return []

    template_path = metadata_path.parent / metadata["eye_template_path"]
    template_data = json.loads(template_path.read_text(encoding="utf-8"))
    template_id = metadata["eye_template_id"]
    template = template_data["templates"].get(template_id)
    if template is None:
        return [f"eye template '{template_id}' does not exist in {template_path}"]

    left_rows = template["left_rows"]
    if template["right_from_left"] != "mirror_horizontal":
        return ["only mirror_horizontal eye templates are supported"]
    right_rows = [row[::-1] for row in left_rows]
    role_colors = {
        role: tuple(color)
        for role, color in metadata["role_colors"].items()
    }

    failures: list[str] = []
    for side, rect, rows in (
        ("left", metadata["left_eye_rect"], left_rows),
        ("right", metadata["right_eye_rect"], right_rows),
    ):
        expected_size = (template["width"], template["height"])
        if tuple(rect[2:]) != expected_size:
            failures.append(
                f"{side} eye rectangle is {rect[2]}x{rect[3]}, "
                f"template expects {expected_size[0]}x{expected_size[1]}"
            )
            continue

        for y, row in enumerate(rows):
            for x, role in enumerate(row):
                if role not in role_colors:
                    failures.append(f"role '{role}' has no color in face metadata")
                    continue
                actual = image.getpixel((rect[0] + x, rect[1] + y))
                expected = role_colors[role]
                if actual != expected:
                    failures.append(
                        f"{side} eye ({x}, {y}) role {role} is {actual}, expected {expected}"
                    )

    if not failures:
        print(f"{image_path}: eye template '{template_id}' matches exactly")
    return failures


def validate_face_dimensions(metadata_path: Path, spec: dict) -> list[str]:
    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    if "face_rect" not in metadata:
        return []

    face_rect = metadata["face_rect"]
    left_rect = metadata["left_eye_rect"]
    right_rect = metadata["right_eye_rect"]
    face_spec = spec["face"]
    failures: list[str] = []

    if face_rect[2] != face_spec["interior_width"]:
        failures.append(
            f"face rectangle is {face_rect[2]} px wide, "
            f"expected {face_spec['interior_width']} px"
        )
    if face_rect[3] != face_spec["interior_height"]:
        failures.append(
            f"face rectangle is {face_rect[3]} px tall, "
            f"expected {face_spec['interior_height']} px"
        )

    shape_id = metadata.get("face_shape_id", "")
    if shape_id != face_spec["shape_id"]:
        failures.append(
            f"face shape is '{shape_id}', expected '{face_spec['shape_id']}'"
        )

    eye_gap = right_rect[0] - (left_rect[0] + left_rect[2])
    if eye_gap != face_spec["eye_gap"]:
        failures.append(
            f"eye gap is {eye_gap} px, expected {face_spec['eye_gap']} px"
        )

    face_left = face_rect[0]
    face_right = face_rect[0] + face_rect[2]
    face_top = face_rect[1]
    face_bottom = face_rect[1] + face_rect[3]
    left_margin = left_rect[0] - face_left
    right_margin = face_right - (right_rect[0] + right_rect[2])
    expected_margin = face_spec["eye_outer_margin"]
    if left_margin != expected_margin or right_margin != expected_margin:
        failures.append(
            f"eye outer margins are {left_margin}px and {right_margin}px, "
            f"expected {expected_margin}px each"
        )

    for side, rect in (("left", left_rect), ("right", right_rect)):
        if rect[1] < face_top or rect[1] + rect[3] > face_bottom:
            failures.append(f"{side} eye is outside the face rectangle vertically")

    if not failures:
        print(
            f"face geometry: width={face_rect[2]}px eye_gap={eye_gap}px "
            f"outer_margins={left_margin}px/{right_margin}px"
        )
    return failures


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("sprites", nargs="+", type=Path)
    parser.add_argument("--spec", type=Path, default=DEFAULT_SPEC)
    parser.add_argument("--face-meta", type=Path)
    args = parser.parse_args()

    if args.face_meta is not None and len(args.sprites) != 1:
        parser.error("--face-meta requires exactly one sprite")

    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    failed = False
    for sprite_path in args.sprites:
        failures = validate_sprite(sprite_path, spec)
        if failures:
            failed = True
            for failure in failures:
                print(f"  FAIL: {failure}")
        else:
            print("  PASS")

    if args.face_meta is not None:
        face_failures = validate_face_symmetry(args.sprites[0], args.face_meta)
        face_failures.extend(validate_face_template(args.sprites[0], args.face_meta))
        face_failures.extend(validate_face_dimensions(args.face_meta, spec))
        if face_failures:
            failed = True
            for failure in face_failures:
                print(f"  FAIL: {failure}")
        else:
            print("  FACE PASS")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
