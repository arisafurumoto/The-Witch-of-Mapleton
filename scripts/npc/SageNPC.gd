extends "res://scripts/core/Interactable.gd"

# Sage's one-request vertical-slice behavior. He appears from day 1, then
# leaves once his quest is done.

@export var quest_id: String = "sage_first_request"
@export var exit_offset: Vector2 = Vector2(0, -48)
@export var walk_duration: float = 0.65
@export var walk_frame_time: float = 0.08

var _busy: bool = false
var _present: bool = false
var _home_position: Vector2 = Vector2.ZERO
var _leaving: bool = false
var _entering: bool = false
var _walk_frames: Dictionary = {}
var _idle_textures: Dictionary = {}
var _frame_tween: Tween

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _sprite: Sprite2D = $Visual

func _ready() -> void:
	super._ready()
	_home_position = position
	_load_animation_textures()
	_set_idle_texture("south")
	_set_present(false)
	DaySystem.day_changed.connect(_on_world_state_changed)
	QuestSystem.quest_state_changed.connect(_on_quest_state_changed)
	_on_world_state_changed(DaySystem.get_day())

func interact() -> void:
	if _busy or not _present:
		return
	interacted.emit()
	_busy = true
	var quest: Dictionary = QuestDatabase.get_quest(quest_id)
	if quest.is_empty():
		_busy = false
		return

	var state: String = QuestSystem.get_quest_state(quest_id)
	var speaker_name: String = String(quest.get("npc_name", "Sage"))
	if state == QuestSystem.STATE_NOT_STARTED:
		await _say(speaker_name, quest.get("start_lines", []))
		QuestSystem.start_quest(quest_id)
	elif QuestSystem.can_turn_in(quest_id):
		await _say(speaker_name, quest.get("complete_lines", []))
		_leaving = true
		if QuestSystem.complete_quest(quest_id):
			await _leave_shop()
		else:
			_leaving = false
	else:
		await _say(speaker_name, quest.get("reminder_lines", []))

	_busy = false

func show_prompt(value: bool) -> void:
	super.show_prompt(value and _present and not _busy)

func _say(speaker_name: String, lines: Array) -> void:
	DialogueBox.show_dialogue(speaker_name, lines)
	if DialogueBox.is_active():
		await DialogueBox.dialogue_finished

func _on_world_state_changed(_day: int) -> void:
	_refresh_presence()

func _on_quest_state_changed(changed_quest_id: String, _state: String) -> void:
	if changed_quest_id == quest_id:
		_refresh_presence()

func _refresh_presence() -> void:
	if _leaving or _entering:
		return
	var state: String = QuestSystem.get_quest_state(quest_id)
	if state == QuestSystem.STATE_COMPLETED:
		_set_present(false)
		return
	if state == QuestSystem.STATE_ACTIVE or state == QuestSystem.STATE_READY:
		_show_or_enter()
		return
	if _can_offer_quest():
		_show_or_enter()
	else:
		_set_present(false)

func _can_offer_quest() -> bool:
	return DaySystem.get_day() >= 1

func _leave_shop() -> void:
	_busy = true
	super.show_prompt(false)
	var move_tween: Tween = _start_walk_to(_home_position + exit_offset, "north", true)
	await move_tween.finished
	_finish_walk_animation("north")
	_set_present(false)
	position = _home_position
	modulate = Color.WHITE
	_leaving = false
	_busy = false

func _set_present(value: bool) -> void:
	_present = value
	visible = value
	monitorable = value
	if _collision_shape:
		_collision_shape.disabled = not value
	if not value:
		super.show_prompt(false)

func _show_or_enter() -> void:
	if _present:
		_set_present(true)
		return
	if _entering:
		return
	_entering = true
	call_deferred("_enter_shop")

func _enter_shop() -> void:
	_entering = true
	_busy = true
	_set_present(true)
	position = _home_position + exit_offset
	modulate = Color.WHITE
	var move_tween: Tween = _start_walk_to(_home_position, "south", false)
	move_tween.finished.connect(_finish_enter_shop)

func _finish_enter_shop() -> void:
	_finish_walk_animation("south")
	_entering = false
	_busy = false

func _start_walk_to(target_position: Vector2, direction: String, fade_out: bool) -> Tween:
	_stop_walk_animation()
	_frame_tween = _start_walk_animation(direction)
	var move_tween: Tween = create_tween()
	move_tween.tween_property(self, "position", target_position, walk_duration)
	if fade_out:
		move_tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), 0.25)
	return move_tween

func _finish_walk_animation(direction: String) -> void:
	_stop_walk_animation()
	_set_idle_texture(direction)

func _stop_walk_animation() -> void:
	if _frame_tween != null and _frame_tween.is_valid():
		_frame_tween.kill()
	_frame_tween = null

func _start_walk_animation(direction: String) -> Tween:
	var frames: Array[Texture2D] = _get_walk_frames(direction)
	if frames.is_empty():
		return null
	_set_visual_texture(frames[0])
	var tween: Tween = create_tween()
	tween.set_loops()
	for texture in frames:
		tween.tween_callback(_set_visual_texture.bind(texture))
		tween.tween_interval(walk_frame_time)
	return tween

func _set_idle_texture(direction: String) -> void:
	var texture: Texture2D = _idle_textures.get(direction, null) as Texture2D
	if texture != null:
		_set_visual_texture(texture)

func _set_visual_texture(texture: Texture2D) -> void:
	_sprite.texture = texture

func _load_animation_textures() -> void:
	var directions: Array[String] = ["north", "south"]
	for direction in directions:
		_walk_frames[direction] = _load_walk_frames(direction)
		var idle_path: String = "res://art/characters/npcs/sage/rotations/%s.png" % direction
		if ResourceLoader.exists(idle_path):
			var texture: Texture2D = load(idle_path) as Texture2D
			if texture != null:
				_idle_textures[direction] = texture

func _load_walk_frames(direction: String) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for index in range(9):
		var path: String = "res://art/characters/npcs/sage/animations/walking/%s/frame_%03d.png" % [direction, index]
		if not ResourceLoader.exists(path):
			continue
		var texture: Texture2D = load(path) as Texture2D
		if texture != null:
			frames.append(texture)
	return frames

func _get_walk_frames(direction: String) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	var value: Variant = _walk_frames.get(direction, [])
	if typeof(value) != TYPE_ARRAY:
		return frames
	for texture in value:
		if texture is Texture2D:
			frames.append(texture)
	return frames
