extends Node2D

# Black cat companion. Smoothly follows the player, keeping a polite distance so
# it never crowds or blocks her. If it falls too far behind (e.g. right after a
# scene change) it snaps to her. Placeholder art for now.

@export var follow_speed: float = 95.0
@export var stop_distance: float = 30.0
@export var snap_distance: float = 280.0

var _target: Node2D

func _ready() -> void:
	_acquire_target()

func _acquire_target() -> void:
	_target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_target):
		_acquire_target()
		return
	var to_target := _target.global_position - global_position
	var dist := to_target.length()
	if dist > snap_distance:
		global_position = _target.global_position
		return
	if dist > stop_distance:
		var step := minf(follow_speed * delta, dist - stop_distance)
		global_position += to_target.normalized() * step
