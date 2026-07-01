extends CanvasLayer

# Autoload singleton UI. Shows a speaker name, optional portrait, and a sequence of
# text lines at the bottom of the screen. Pressing interact advances to the next line;
# after the last line it closes and emits dialogue_finished.

signal dialogue_finished

@onready var _panel: PanelContainer = $Panel
@onready var _portrait_texture: TextureRect = $PortraitTexture
@onready var _name_plate: PanelContainer = $NamePlate
@onready var _name_plate_label: Label = $NamePlate/Margin/NamePlateLabel
@onready var _name_label: Label = $Panel/Margin/VBox/NameLabel
@onready var _line_label: Label = $Panel/Margin/VBox/LineLabel

const PORTRAIT_PATHS := {
	"marigold": {
		"default": "res://art/characters/marigold/portraits/default.png",
		"concerned": "res://art/characters/marigold/portraits/concerned.png",
		"thinking": "res://art/characters/marigold/portraits/thinking.png",
		"laugh": "res://art/characters/marigold/portraits/laugh.png",
	},
	"sage": {
		"default": "res://art/characters/npcs/sage/portraits/default.png",
		"neutral": "res://art/characters/npcs/sage/portraits/neutral.png",
		"concerned": "res://art/characters/npcs/sage/portraits/concerned.png",
		"thinking": "res://art/characters/npcs/sage/portraits/thinking.png",
		"laugh": "res://art/characters/npcs/sage/portraits/laugh.png",
		"blushed": "res://art/characters/npcs/sage/portraits/blushed.png",
	},
	"camellia": {
		"default": "res://art/characters/npcs/camellia/portraits/default.png",
		"concerned": "res://art/characters/npcs/camellia/portraits/concerned.png",
		"thinking": "res://art/characters/npcs/camellia/portraits/thinking.png",
		"laugh": "res://art/characters/npcs/camellia/portraits/laugh.png",
		"blushed": "res://art/characters/npcs/camellia/portraits/blushed.png",
	},
}

var _entries: Array[Dictionary] = []
var _index: int = 0
var _active: bool = false
var _just_opened: bool = false
var _current_portrait_path: String = ""

const LEFT_PORTRAIT_LEFT := 4.0
const LEFT_PORTRAIT_RIGHT := 154.0
const LEFT_NAME_LEFT := 8.0
const LEFT_NAME_RIGHT := 150.0
const RIGHT_PORTRAIT_LEFT := 486.0
const RIGHT_PORTRAIT_RIGHT := 636.0
const RIGHT_NAME_LEFT := 490.0
const RIGHT_NAME_RIGHT := 632.0
const PORTRAIT_TOP := 194.0
const PORTRAIT_BOTTOM := 344.0
const NAME_TOP := 324.0
const NAME_BOTTOM := 352.0
const PANEL_MARGIN := 8.0
const PORTRAIT_PANEL_MARGIN := 154.0

func _ready() -> void:
	layer = 100
	_panel.visible = false
	_portrait_texture.visible = false
	_name_plate.visible = false

func is_active() -> bool:
	return _active

func is_portrait_visible() -> bool:
	return _portrait_texture.visible

func get_current_portrait_path() -> String:
	return _current_portrait_path

func get_portrait_path_for_speaker(speaker: String, expression: String = "default") -> String:
	var speaker_id: String = _speaker_id(speaker)
	var portrait_value: Variant = PORTRAIT_PATHS.get(speaker_id, {})
	if typeof(portrait_value) != TYPE_DICTIONARY:
		return ""
	var portraits: Dictionary = portrait_value
	var expression_id: String = expression.strip_edges().to_lower()
	if expression_id == "":
		expression_id = "default"
	var path: String = String(portraits.get(expression_id, ""))
	if path == "" and expression_id != "default":
		path = String(portraits.get("default", ""))
	return path

func show_dialogue(speaker: String, lines: Array) -> void:
	if lines.is_empty():
		return
	_entries = _normalise_entries(speaker, lines)
	if _entries.is_empty():
		return
	_index = 0
	_active = true
	_just_opened = true
	_show_current_entry()
	_panel.visible = true

func _process(_delta: float) -> void:
	# Clear the open-guard one frame after opening so the press that started the
	# dialogue doesn't also advance it.
	if _just_opened:
		_just_opened = false

func _unhandled_input(event: InputEvent) -> void:
	if not _active or _just_opened:
		return
	if event.is_action_pressed("interact"):
		_advance()
		get_viewport().set_input_as_handled()

func _advance() -> void:
	_index += 1
	if _index >= _entries.size():
		_close()
	else:
		_show_current_entry()

func _close() -> void:
	_active = false
	_panel.visible = false
	_hide_portrait()
	dialogue_finished.emit()

func _show_current_entry() -> void:
	var entry: Dictionary = _entries[_index]
	var speaker: String = String(entry.get("speaker", ""))
	var expression: String = String(entry.get("expression", "default"))
	var has_portrait: bool = _apply_portrait(speaker, expression)
	var speaker_id: String = _speaker_id(speaker)
	_name_label.text = speaker
	_name_label.visible = speaker != "" and not has_portrait
	_name_plate_label.text = speaker
	_name_plate.visible = speaker != "" and has_portrait
	if has_portrait:
		_position_portrait(speaker_id)
	_apply_panel_offsets(speaker_id, has_portrait)
	_line_label.text = String(entry.get("text", ""))

func _normalise_entries(speaker: String, lines: Array) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for line in lines:
		var entry: Dictionary = _normalise_entry(speaker, line)
		if not String(entry.get("text", "")).is_empty():
			entries.append(entry)
	return entries

func _normalise_entry(default_speaker: String, value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {
			"speaker": default_speaker,
			"expression": "default",
			"text": str(value),
		}
	var data: Dictionary = value
	return {
		"speaker": String(data.get("speaker", default_speaker)),
		"expression": String(data.get("expression", "default")),
		"text": String(data.get("text", data.get("line", ""))),
	}

func _apply_portrait(speaker: String, expression: String) -> bool:
	_current_portrait_path = get_portrait_path_for_speaker(speaker, expression)
	if _current_portrait_path == "":
		_hide_portrait()
		return false
	var texture: Texture2D = _load_portrait_texture(_current_portrait_path)
	if texture == null:
		_hide_portrait()
		return false
	_portrait_texture.texture = texture
	_portrait_texture.visible = true
	return true

func _hide_portrait() -> void:
	_current_portrait_path = ""
	_portrait_texture.texture = null
	_portrait_texture.visible = false
	_name_plate.visible = false

func _position_portrait(speaker_id: String) -> void:
	var on_right: bool = _speaker_uses_right_portrait(speaker_id)
	_portrait_texture.offset_left = RIGHT_PORTRAIT_LEFT if on_right else LEFT_PORTRAIT_LEFT
	_portrait_texture.offset_right = RIGHT_PORTRAIT_RIGHT if on_right else LEFT_PORTRAIT_RIGHT
	_portrait_texture.offset_top = PORTRAIT_TOP
	_portrait_texture.offset_bottom = PORTRAIT_BOTTOM
	_name_plate.offset_left = RIGHT_NAME_LEFT if on_right else LEFT_NAME_LEFT
	_name_plate.offset_right = RIGHT_NAME_RIGHT if on_right else LEFT_NAME_RIGHT
	_name_plate.offset_top = NAME_TOP
	_name_plate.offset_bottom = NAME_BOTTOM

func _apply_panel_offsets(speaker_id: String, has_portrait: bool) -> void:
	if not has_portrait:
		_panel.offset_left = PANEL_MARGIN
		_panel.offset_right = -PANEL_MARGIN
		return
	if _speaker_uses_right_portrait(speaker_id):
		_panel.offset_left = PANEL_MARGIN
		_panel.offset_right = -PORTRAIT_PANEL_MARGIN
		return
	_panel.offset_left = PORTRAIT_PANEL_MARGIN
	_panel.offset_right = -PANEL_MARGIN

func _speaker_uses_right_portrait(speaker_id: String) -> bool:
	return speaker_id == "marigold"

func _load_portrait_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if _imported_texture_is_ready(path) and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

func _imported_texture_is_ready(path: String) -> bool:
	var import_path: String = path + ".import"
	if not FileAccess.file_exists(import_path):
		return true
	var text: String = FileAccess.get_file_as_string(import_path)
	for line in text.split("\n"):
		if not line.begins_with("dest_files="):
			continue
		var start: int = line.find("\"")
		var end: int = line.find("\"", start + 1)
		if start >= 0 and end > start:
			return FileAccess.file_exists(line.substr(start + 1, end - start - 1))
	return false

func _speaker_id(speaker: String) -> String:
	return speaker.strip_edges().to_lower().replace(" ", "_")
