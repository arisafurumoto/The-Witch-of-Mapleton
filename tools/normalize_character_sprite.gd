extends SceneTree

const SPEC_PATH := "res://art/style_reference/character_standard.json"


func _init() -> void:
	var spec: Dictionary = _load_spec()
	if spec.is_empty():
		quit(1)
		return
	var canvas_data: Dictionary = spec.get("canvas", {}) as Dictionary
	var canvas_size := Vector2i(int(canvas_data.get("width", 0)), int(canvas_data.get("height", 0)))
	var feet_baseline_y: int = int(canvas_data.get("feet_baseline_y", 0))

	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 3:
		printerr("Usage: normalize_character_sprite.gd <input.png> <output.png> <visible_height>")
		quit(2)
		return

	var input_path: String = args[0]
	var output_path: String = args[1]
	var target_height: int = args[2].to_int()
	if target_height <= 0 or target_height > feet_baseline_y:
		printerr("Visible height must be between 1 and %d" % feet_baseline_y)
		quit(2)
		return

	var source: Image = Image.load_from_file(input_path)
	if source.is_empty():
		printerr("Could not load image: %s" % input_path)
		quit(1)
		return

	source.convert(Image.FORMAT_RGBA8)
	# Chroma removal can leave a soft matte. Threshold before measuring so the
	# requested visible dimensions survive normalization exactly.
	_make_alpha_binary(source)
	var used_rect: Rect2i = source.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		printerr("Image has no visible pixels: %s" % input_path)
		quit(1)
		return

	var sprite: Image = source.get_region(used_rect)
	var target_width: int = maxi(1, roundi(float(sprite.get_width()) * float(target_height) / float(sprite.get_height())))
	if target_width > canvas_size.x:
		printerr("Normalized sprite would exceed the %d px canvas width" % canvas_size.x)
		quit(1)
		return

	sprite.resize(target_width, target_height, Image.INTERPOLATE_NEAREST)
	_make_alpha_binary(sprite)

	var canvas: Image = Image.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0.0, 0.0, 0.0, 0.0))
	var destination := Vector2i((canvas_size.x - target_width) / 2, feet_baseline_y - target_height)
	canvas.blit_rect(sprite, Rect2i(Vector2i.ZERO, sprite.get_size()), destination)

	var error: Error = canvas.save_png(output_path)
	if error != OK:
		printerr("Could not save image: %s" % output_path)
		quit(1)
		return

	print("Wrote %s (%dx%d visible, baseline y=%d)" % [output_path, target_width, target_height, feet_baseline_y])
	quit()


func _load_spec() -> Dictionary:
	if not FileAccess.file_exists(SPEC_PATH):
		printerr("Missing character standard: %s" % SPEC_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SPEC_PATH))
	if not parsed is Dictionary:
		printerr("Invalid character standard JSON: %s" % SPEC_PATH)
		return {}
	return parsed as Dictionary


func _make_alpha_binary(image: Image) -> void:
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if color.a < 0.5:
				image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
			else:
				color.a = 1.0
				image.set_pixel(x, y, color)
