extends CharacterBody2D

@export var max_speed: float = 90.0
@export var acceleration: float = 900.0
@export var friction: float = 1100.0

# Clockwise from east, matching the SpriteFrames animation suffixes.
const DIRECTIONS := [
	"east", "south_east", "south", "south_west",
	"west", "north_west", "north", "north_east",
]

@onready var sprite: AnimatedSprite2D = $Sprite

var facing: String = "south"

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()
	_update_animation()

func _update_animation() -> void:
	if velocity.length() > 5.0:
		facing = _direction_name(velocity)
		sprite.play("walk_" + facing)
	else:
		sprite.play("idle_" + facing)

func _direction_name(v: Vector2) -> String:
	var index := int(round(rad_to_deg(v.angle()) / 45.0))
	index = (index % 8 + 8) % 8
	return DIRECTIONS[index]
