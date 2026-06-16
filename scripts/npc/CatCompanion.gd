extends Node2D

# Saffron, the black cat companion. Smoothly follows the player, keeping a polite
# distance so she never crowds or blocks her. If she falls too far behind (e.g.
# right after a scene change) she snaps to the player. Faces and animates in the
# direction she walks.

@export var follow_speed: float = 95.0
@export var stop_distance: float = 46.0
@export var snap_distance: float = 280.0
@export var idle_turn_min_time: float = 1.8
@export var idle_turn_max_time: float = 4.2

# Clockwise from east, matching the SpriteFrames animation suffixes.
const DIRECTIONS := [
	"east", "south_east", "south", "south_west",
	"west", "north_west", "north", "north_east",
]

@onready var sprite: AnimatedSprite2D = $Sprite

var _target: Node2D
var facing: String = "south"
var _idle_turn_timer: float = 0.0
var _was_idle: bool = false

func _ready() -> void:
	_acquire_target()
	_reset_idle_turn_timer()

func _acquire_target() -> void:
	_target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_target):
		_acquire_target()
		_play_idle()
		return
	var to_target := _target.global_position - global_position
	var dist := to_target.length()
	if dist > snap_distance:
		global_position = _target.global_position
		_play_idle()
		return
	if dist > stop_distance:
		_was_idle = false
		var step := minf(follow_speed * delta, dist - stop_distance)
		global_position += to_target.normalized() * step
		facing = _direction_name(to_target)
		sprite.play("walk_" + facing)
	else:
		_update_idle(delta)

func _play_idle() -> void:
	sprite.play("idle_" + facing)

func _update_idle(delta: float) -> void:
	if not _was_idle:
		_was_idle = true
		_reset_idle_turn_timer()
		_play_idle()
		return

	_idle_turn_timer -= delta
	if _idle_turn_timer <= 0.0:
		_choose_idle_facing()
		_reset_idle_turn_timer()
	_play_idle()

func _reset_idle_turn_timer() -> void:
	_idle_turn_timer = randf_range(idle_turn_min_time, idle_turn_max_time)

func _choose_idle_facing() -> void:
	var current_index := DIRECTIONS.find(facing)
	if current_index == -1:
		current_index = DIRECTIONS.find("south")

	var roll := randf()
	if roll < 0.45 and is_instance_valid(_target):
		var to_target := _target.global_position - global_position
		if to_target.length() > 1.0:
			facing = _direction_name(to_target)
			return

	var offset := 0
	if roll < 0.75:
		offset = -1 if randf() < 0.5 else 1
	else:
		offset = randi_range(-2, 2)
	var next_index := (current_index + offset) % DIRECTIONS.size()
	next_index = (next_index + DIRECTIONS.size()) % DIRECTIONS.size()
	facing = DIRECTIONS[next_index]

func _direction_name(v: Vector2) -> String:
	var index := int(round(rad_to_deg(v.angle()) / 45.0))
	index = (index % 8 + 8) % 8
	return DIRECTIONS[index]
