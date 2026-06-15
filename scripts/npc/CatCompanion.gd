extends Node2D

# Saffron, the black cat companion. Smoothly follows the player, keeping a polite
# distance so she never crowds or blocks her. If she falls too far behind (e.g.
# right after a scene change) she snaps to the player. Faces and animates in the
# direction she walks.

@export var follow_speed: float = 95.0
@export var stop_distance: float = 30.0
@export var snap_distance: float = 280.0

# Clockwise from east, matching the SpriteFrames animation suffixes.
const DIRECTIONS := [
	"east", "south_east", "south", "south_west",
	"west", "north_west", "north", "north_east",
]

@onready var sprite: AnimatedSprite2D = $Sprite

var _target: Node2D
var facing: String = "south"

func _ready() -> void:
	_acquire_target()

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
		var step := minf(follow_speed * delta, dist - stop_distance)
		global_position += to_target.normalized() * step
		facing = _direction_name(to_target)
		sprite.play("walk_" + facing)
	else:
		_play_idle()

func _play_idle() -> void:
	sprite.play("idle_" + facing)

func _direction_name(v: Vector2) -> String:
	var index := int(round(rad_to_deg(v.angle()) / 45.0))
	index = (index % 8 + 8) % 8
	return DIRECTIONS[index]
