#!/usr/bin/env python3
"""Generate Sage's 8-direction PixelLab Pro character draft.

Reads the PixelLab API token from PIXELLAB_SECRET or stdin. The token is never
written to disk.
"""

from __future__ import annotations

import base64
import getpass
import json
import os
import sys
import time
import urllib.error
import urllib.request
import zipfile
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "tmp" / "pixellab_sage"
API_BASE = "https://api.pixellab.ai/v2"

CONCEPT_SOURCE = Path("/Users/arisafurumoto/Downloads/Generated image 1 (1).png")
MARIGOLD_SOUTH = (
    ROOT
    / "art"
    / "characters"
    / "marigold"
    / "with_staff"
    / "rotations"
    / "south.png"
)
SAGE_SPRITE = ROOT / "art" / "characters" / "npcs" / "sage.png"
SAGE_ROTATIONS = ROOT / "art" / "characters" / "npcs" / "sage" / "rotations"
ROTATION_NAMES = [
    "south",
    "south-east",
    "east",
    "north-east",
    "north",
    "north-west",
    "west",
    "south-west",
]


def require_file(path: Path) -> None:
    if not path.exists():
        raise FileNotFoundError(f"Missing required file: {path}")


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError("Image has no non-transparent pixels")
    return bbox


def paste_fit(canvas: Image.Image, sprite_path: Path, box: tuple[int, int, int, int]) -> None:
    source = Image.open(sprite_path).convert("RGBA")
    crop = source.crop(alpha_bbox(source))
    max_w = box[2] - box[0]
    max_h = box[3] - box[1]
    scale = min(float(max_w) / float(crop.width), float(max_h) / float(crop.height))
    size = (
        max(1, int(round(crop.width * scale))),
        max(1, int(round(crop.height * scale))),
    )
    crop = crop.resize(size, Image.Resampling.NEAREST)
    x = box[0] + (max_w - size[0]) // 2
    y = box[1] + max_h - size[1]
    canvas.alpha_composite(crop, (x, y))


def prepare_style_reference() -> Path:
    style = Image.new("RGBA", (168, 168), (0, 0, 0, 0))
    paste_fit(style, MARIGOLD_SOUTH, (44, 18, 124, 158))
    path = OUT_DIR / "mapleton_style_reference.png"
    style.save(path)
    return path


def prepare_concept_image() -> Path:
    source = Image.open(CONCEPT_SOURCE).convert("RGBA")
    pixels = source.load()
    width, height = source.size

    # The current concept has a flat magenta background. Remove it before using
    # the art as a concept so the model follows the character, not the key color.
    key_r, key_g, key_b = pixels[0, 0][:3]
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if (
                a > 0
                and abs(r - key_r) <= 24
                and abs(g - key_g) <= 24
                and abs(b - key_b) <= 24
            ):
                pixels[x, y] = (r, g, b, 0)

    crop = source.crop(alpha_bbox(source))
    longest = max(crop.size)
    if longest > 1024:
        scale = 1024.0 / float(longest)
        crop = crop.resize(
            (max(1, int(round(crop.width * scale))), max(1, int(round(crop.height * scale)))),
            Image.Resampling.NEAREST,
        )

    canvas = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    x = (1024 - crop.width) // 2
    y = 1024 - crop.height
    canvas.alpha_composite(crop, (x, y))
    path = OUT_DIR / "sage_concept_transparent_1024.png"
    canvas.save(path)
    return path


def encode_image(path: Path) -> dict[str, str]:
    data = base64.b64encode(path.read_bytes()).decode("ascii")
    return {"base64": data}


def request_json(path: str, token: str, payload: dict | None = None) -> dict:
    url = f"{API_BASE}{path}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
    }
    data = None
    method = "GET"
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
        method = "POST"
    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"PixelLab HTTP {exc.code}: {body}") from exc


def scrub_large_images(value):
    if isinstance(value, dict):
        result = {}
        for key, item in value.items():
            if key == "base64":
                result[key] = "<base64 redacted>"
            else:
                result[key] = scrub_large_images(item)
        return result
    if isinstance(value, list):
        return [scrub_large_images(item) for item in value]
    return value


def download_zip(character_id: str, token: str) -> Path:
    url = f"{API_BASE}/characters/{character_id}/zip"
    headers = {"Authorization": f"Bearer {token}"}
    request = urllib.request.Request(url, headers=headers, method="GET")
    zip_path = OUT_DIR / "sage_pixellab_character.zip"
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            zip_path.write_bytes(response.read())
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"PixelLab ZIP HTTP {exc.code}: {body}") from exc
    return zip_path


def component_boxes(image: Image.Image) -> list[tuple[int, int, int, int]]:
    alpha = image.getchannel("A")
    width, height = image.size
    pixels = alpha.load()
    seen: set[tuple[int, int]] = set()
    boxes: list[tuple[int, int, int, int]] = []

    for y in range(height):
        for x in range(width):
            if pixels[x, y] == 0 or (x, y) in seen:
                continue

            queue = [(x, y)]
            seen.add((x, y))
            xs: list[int] = []
            ys: list[int] = []
            count = 0
            while len(queue) > 0:
                cx, cy = queue.pop()
                xs.append(cx)
                ys.append(cy)
                count += 1
                for nx in (cx - 1, cx, cx + 1):
                    for ny in (cy - 1, cy, cy + 1):
                        if nx < 0 or ny < 0 or nx >= width or ny >= height:
                            continue
                        if (nx, ny) in seen or pixels[nx, ny] == 0:
                            continue
                        seen.add((nx, ny))
                        queue.append((nx, ny))

            if count > 1000:
                boxes.append((min(xs), min(ys), max(xs) + 1, max(ys) + 1))

    return sorted(boxes, key=lambda box: box[0])


def cleaned_rotation(source_path: Path, direction: str) -> Image.Image:
    source = Image.open(source_path).convert("RGBA")
    boxes = component_boxes(source)
    if len(boxes) == 0:
        raise RuntimeError(f"No character component found for {direction}")

    # PixelLab can echo two figures if the style/concept cues are busy. Pick the
    # copy closest to the named side; single-figure frames pass through unchanged.
    if len(boxes) == 1:
        bbox = boxes[0]
    elif direction in ("south", "south-east", "east", "north-east"):
        bbox = boxes[0]
    else:
        bbox = boxes[-1]

    crop = source.crop(bbox)
    canvas = Image.new("RGBA", (180, 180), (0, 0, 0, 0))
    x = (180 - crop.width) // 2
    y = 135 - crop.height
    canvas.alpha_composite(crop, (x, y))
    return canvas


def write_cleaned_rotations(extract_dir: Path) -> None:
    rotation_dirs = list(extract_dir.glob("*/rotations"))
    if len(rotation_dirs) != 1:
        raise RuntimeError(f"Expected one rotations folder, found {len(rotation_dirs)}")

    SAGE_ROTATIONS.mkdir(parents=True, exist_ok=True)
    rotation_dir = rotation_dirs[0]
    for direction in ROTATION_NAMES:
        image = cleaned_rotation(rotation_dir / f"{direction}.png", direction)
        image.save(SAGE_ROTATIONS / f"{direction}.png")
        if direction == "south":
            image.save(SAGE_SPRITE)


def main() -> int:
    token = os.environ.get("PIXELLAB_SECRET", "").strip()
    if token == "":
        if sys.stdin.isatty():
            token = getpass.getpass("PixelLab token: ").strip()
        else:
            token = sys.stdin.readline().strip()
    if token == "":
        print("Missing PixelLab token", file=sys.stderr)
        return 2

    for path in (CONCEPT_SOURCE, MARIGOLD_SOUTH):
        require_file(path)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    concept_path = prepare_concept_image()
    style_path = prepare_style_reference()

    payload = {
        "description": (
            "Sage, a slim gentle elf plant shop owner and apprentice herbalist for a cozy "
            "top-down 3/4 pixel-art witch life sim. Silver-white tousled wavy hair with "
            "swept, voluminous fantasy-elf layers, large pointed elf ears, warm brown eyes, "
            "cream rolled-sleeve shirt, earthy brown apron with plant patch, small "
            "herbalist pockets, shears, glass vials, dark trousers, brown boots. Match "
            "Marigold's compact RPG sprite proportions: chibi head-to-body balance, "
            "readable small face, short compact limbs, not realistic long fashion "
            "proportions. He should be only slightly taller than Marigold and the generic "
            "customer. Feet centered at the bottom of each frame. Generate all 8 rotations."
        ),
        "image_size": {"width": 96, "height": 96},
        "method": "create_from_concept",
        "view": "low top-down",
        "template_id": "mannequin",
        "concept_image": encode_image(concept_path),
        "reference_image": encode_image(style_path),
        "style_description": (
            "Match the Mapleton in-game sprites used in the reference image: modern cozy "
            "top-down 3/4 pixel art, crisp nearest-neighbor pixels, warm handcrafted "
            "autumn fantasy palette, simple readable shapes at small scale, black/brown "
            "pixel outline, transparent background, no shadow, no text. Keep the same "
            "head/body proportion as the style reference, with the character only a little "
            "taller than Marigold."
        ),
        "no_background": True,
    }

    (OUT_DIR / "create_character_pro_payload_redacted.json").write_text(
        json.dumps({**payload, "concept_image": "<base64 redacted>", "reference_image": "<base64 redacted>"}, indent=2),
        encoding="utf-8",
    )

    response = request_json("/create-character-pro", token, payload)
    (OUT_DIR / "create_character_pro_response.json").write_text(json.dumps(response, indent=2), encoding="utf-8")
    print(json.dumps(response, indent=2))

    job_id = response["background_job_id"]
    character_id = response["character_id"]
    status = response.get("status", "processing")
    final_status = response
    for _index in range(90):
        if status in ("completed", "failed"):
            break
        time.sleep(5)
        final_status = request_json(f"/background-jobs/{job_id}", token)
        (OUT_DIR / "background_job_status.json").write_text(
            json.dumps(scrub_large_images(final_status), indent=2),
            encoding="utf-8",
        )
        status = final_status.get("status", final_status.get("job_status", status))
        print(f"job {job_id}: {status}")

    if status != "completed":
        print(json.dumps(final_status, indent=2), file=sys.stderr)
        return 1

    zip_path = download_zip(character_id, token)
    extract_dir = OUT_DIR / "character_export"
    extract_dir.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(zip_path, "r") as archive:
        archive.extractall(extract_dir)
    write_cleaned_rotations(extract_dir)

    print(f"Downloaded {zip_path}")
    print(f"Extracted {extract_dir}")
    print(f"Wrote cleaned rotations to {SAGE_ROTATIONS}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
