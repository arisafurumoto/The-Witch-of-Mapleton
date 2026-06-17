#!/usr/bin/env python3
import os

PROJECT = "/Users/arisafurumoto/Projects/claude/The-Witch-of-Mapleton"
BASE_RES = "res://art/characters/marigold"
BASE_FS = os.path.join(PROJECT, "art/characters/marigold")
WALK_SUBDIR = "animations/walking_with_staff"
OUT = os.path.join(BASE_FS, "Marigold.tres")
WALK_FRAMES = 9

# folder name -> animation suffix
DIRS = [
    ("east", "east"),
    ("south-east", "south_east"),
    ("south", "south"),
    ("south-west", "south_west"),
    ("west", "west"),
    ("north-west", "north_west"),
    ("north", "north"),
    ("north-east", "north_east"),
]

WALK_SPEED = 12.0
IDLE_SPEED = 5.0

ext_lines = []
ext_id_by_path = {}
_next = [1]

def ext_id(res_path):
    if res_path not in ext_id_by_path:
        rid = f"t{_next[0]}"
        _next[0] += 1
        ext_id_by_path[res_path] = rid
        ext_lines.append(f'[ext_resource type="Texture2D" path="{res_path}" id="{rid}"]')
    return ext_id_by_path[res_path]

animations = []

for folder, suffix in DIRS:
    frames = []
    for i in range(WALK_FRAMES):
        fname = f"frame_{i:03d}.png"
        fs_path = os.path.join(BASE_FS, WALK_SUBDIR, folder, fname)
        if not os.path.exists(fs_path):
            raise SystemExit("Missing walk frame: " + fs_path)
        rid = ext_id(f"{BASE_RES}/{WALK_SUBDIR}/{folder}/{fname}")
        frames.append('{\n"duration": 1.0,\n"texture": ExtResource("%s")\n}' % rid)
    animations.append(
        '{\n"frames": [%s],\n"loop": true,\n"name": &"walk_%s",\n"speed": %s\n}'
        % (", ".join(frames), suffix, WALK_SPEED)
    )

for folder, suffix in DIRS:
    fs_path = os.path.join(BASE_FS, "rotations", f"{folder}.png")
    if not os.path.exists(fs_path):
        raise SystemExit("Missing rotation: " + fs_path)
    rid = ext_id(f"{BASE_RES}/rotations/{folder}.png")
    frame = '{\n"duration": 1.0,\n"texture": ExtResource("%s")\n}' % rid
    animations.append(
        '{\n"frames": [%s],\n"loop": true,\n"name": &"idle_%s",\n"speed": %s\n}'
        % (frame, suffix, IDLE_SPEED)
    )

load_steps = len(ext_id_by_path) + 1
out = [f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=3]', ""]
out.extend(ext_lines)
out += ["", "[resource]", "animations = [" + ", ".join(animations) + "]", ""]

with open(OUT, "w") as fp:
    fp.write("\n".join(out))

print("Wrote", OUT)
print("textures:", len(ext_id_by_path), "animations:", len(animations), "load_steps:", load_steps)
