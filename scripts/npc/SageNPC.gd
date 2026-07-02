extends "res://scripts/core/Interactable.gd"

# Sage's one-request vertical-slice behavior. He appears from day 1, then
# leaves once his quest is done.

@export var quest_id: String = "sage_first_request"
@export var entrance_path: NodePath
@export var interior_waypoint_path: NodePath
@export var home_facing: String = "south"

const DIRECTIONS := [
	"east", "south_east", "south", "south_west",
	"west", "north_west", "north", "north_east",
]
const WALK_SPEED: float = 105.0
const FOREST_SCENE: String = "res://scenes/world/ForestClearing.tscn"

var _busy: bool = false
var _present: bool = false
var _home_position: Vector2 = Vector2.ZERO
var _leaving: bool = false
var _entering: bool = false
var _returned_from_forest: bool = false

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _sprite: AnimatedSprite2D = $Visual

func _ready() -> void:
	super._ready()
	_home_position = position
	_returned_from_forest = String(get_tree().root.get_meta("transition_from_scene", "")) == FOREST_SCENE
	_sprite.play("idle_" + home_facing)
	_set_present(false)
	DaySystem.day_changed.connect(_on_world_state_changed)
	QuestSystem.quest_state_changed.connect(_on_quest_state_changed)
	_refresh_presence()

func interact() -> void:
	if _busy or not _present:
		return
	interacted.emit()
	_busy = true
	_face_player()
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
	ShopState.clear_visitor_arrival(quest_id)
	_refresh_presence()

func _on_quest_state_changed(changed_quest_id: String, _state: String) -> void:
	if changed_quest_id == quest_id:
		ShopState.clear_visitor_arrival(quest_id)
		_refresh_presence()

func _refresh_presence() -> void:
	if _leaving or _entering:
		return
	var state: String = QuestSystem.get_quest_state(quest_id)
	if state == QuestSystem.STATE_COMPLETED:
		_set_present(false)
		return
	if state == QuestSystem.STATE_ACTIVE or state == QuestSystem.STATE_READY:
		_show_at_home()
		return
	if _can_offer_quest() and (_returned_from_forest or ShopState.has_visitor_arrived(quest_id)):
		_show_at_home()
	elif _can_offer_quest():
		_show_or_enter()
	else:
		_set_present(false)

func _can_offer_quest() -> bool:
	return QuestSystem.is_quest_available(quest_id)

func _leave_shop() -> void:
	_busy = true
	super.show_prompt(false)
	_set_collision_enabled(false)
	await _walk_to(_interior_waypoint_position())
	await _walk_to(_entrance_position())
	_set_present(false)
	position = _home_position
	modulate = Color.WHITE
	_leaving = false
	_busy = false

func _set_present(value: bool) -> void:
	_present = value
	visible = value
	monitorable = value
	_set_collision_enabled(value and not _busy)
	if value:
		add_to_group("closed_shop_visitors")
	else:
		remove_from_group("closed_shop_visitors")
		super.show_prompt(false)

func _set_collision_enabled(value: bool) -> void:
	if _collision_shape:
		_collision_shape.disabled = not value

func _show_or_enter() -> void:
	if _present:
		_set_present(true)
		return
	if _entering:
		return
	_entering = true
	call_deferred("_enter_shop")

func _show_at_home() -> void:
	ShopState.set_visitor_arrived(quest_id)
	position = _home_position
	_sprite.play("idle_" + home_facing)
	_busy = false
	_set_present(true)

func _enter_shop() -> void:
	_entering = true
	_busy = true
	ShopState.set_visitor_arrived(quest_id)
	position = _entrance_position()
	_set_present(true)
	_set_collision_enabled(false)
	await _walk_to(_interior_waypoint_position())
	await _walk_to(_home_position)
	_finish_enter_shop()

func _finish_enter_shop() -> void:
	_sprite.play("idle_" + home_facing)
	_entering = false
	_busy = false
	_set_collision_enabled(true)

func _walk_to(target_position: Vector2) -> void:
	var movement: Vector2 = target_position - position
	var direction: String = _direction_for(movement)
	var duration: float = movement.length() / WALK_SPEED
	_sprite.play("walk_" + direction)
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target_position, duration)
	await tween.finished
	_sprite.play("idle_" + direction)

func _direction_for(delta_position: Vector2) -> String:
	var index: int = int(round(rad_to_deg(delta_position.angle()) / 45.0))
	index = (index % 8 + 8) % 8
	return DIRECTIONS[index]

func _face_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var direction := _direction_for(player.global_position - global_position)
	_sprite.play("idle_" + direction)

func _entrance_position() -> Vector2:
	var entrance := get_node_or_null(entrance_path) as Node2D
	if entrance != null:
		return entrance.position
	return _home_position

func _interior_waypoint_position() -> Vector2:
	var waypoint := get_node_or_null(interior_waypoint_path) as Node2D
	if waypoint != null:
		return waypoint.position
	return _entrance_position()
