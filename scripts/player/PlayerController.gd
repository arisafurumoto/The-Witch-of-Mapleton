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
@onready var detector: Area2D = $InteractionDetector

var facing: String = "south"
var _interactables: Array[Area2D] = []

func _ready() -> void:
	add_to_group("player")
	SaveSystem.apply_pending_player_position(self)
	_apply_transition_state()
	detector.area_entered.connect(_on_detector_area_entered)
	detector.area_exited.connect(_on_detector_area_exited)

func _physics_process(delta: float) -> void:
	if HUD.is_day_transition_active():
		velocity = Vector2.ZERO
		_update_animation()
		_update_prompts()
		return
	# Freeze movement while a dialogue or modal crafting panel is open.
	var input_dir := Vector2.ZERO
	if not DialogueBox.is_active() and not CauldronCraftingPanel.is_active() and not HUD.is_day_transition_active():
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()
	_update_animation()
	_update_prompts()

func _unhandled_input(event: InputEvent) -> void:
	# While UI is open, interact is handled by that UI.
	if DialogueBox.is_active() or CauldronCraftingPanel.is_active() or HUD.is_day_transition_active():
		return
	if event.is_action_pressed("interact"):
		var target := _nearest_interactable()
		if target:
			target.interact()

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

func _on_detector_area_entered(area: Area2D) -> void:
	if area.has_method("interact") and not _interactables.has(area):
		_interactables.append(area)

func _on_detector_area_exited(area: Area2D) -> void:
	_interactables.erase(area)
	if area.has_method("show_prompt"):
		area.show_prompt(false)

func _nearest_interactable() -> Area2D:
	var nearest: Area2D = null
	var best := INF
	for it in _interactables:
		if not is_instance_valid(it):
			continue
		var d := global_position.distance_to(it.global_position)
		if d < best:
			best = d
			nearest = it
	return nearest

func _update_prompts() -> void:
	var nearest := _nearest_interactable()
	for it in _interactables:
		if it.has_method("show_prompt"):
			it.show_prompt(it == nearest)

func _apply_transition_state() -> void:
	var root := get_tree().root
	if root.has_meta("target_player_position"):
		var target_position: Variant = root.get_meta("target_player_position")
		root.remove_meta("target_player_position")
		if typeof(target_position) == TYPE_VECTOR2:
			global_position = target_position
	if root.has_meta("target_player_facing"):
		var target_facing := String(root.get_meta("target_player_facing"))
		root.remove_meta("target_player_facing")
		if DIRECTIONS.has(target_facing):
			facing = target_facing
			sprite.play("idle_" + facing)
