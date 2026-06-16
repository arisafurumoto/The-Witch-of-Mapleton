extends "res://scripts/core/Interactable.gd"

# A gatherable world node (Moonleaf bush, Forest Water spring, ...).
# Interacting once gives its item, then it depletes until the next day.

@export var gatherable_id: String = ""
@export var item_id: String = ""
@export var item_quantity: int = 1
@export var reset_daily: bool = true
@export var visual_texture: Texture2D
@export var visual_color: Color = Color(0.36, 0.6, 0.36)

var depleted: bool = false

func _ready() -> void:
	super._ready()
	add_to_group("gatherables")
	if _visual is Sprite2D:
		var sprite: Sprite2D = _visual as Sprite2D
		if visual_texture != null:
			sprite.texture = visual_texture
		if sprite.texture != null:
			var texture_size: Vector2 = sprite.texture.get_size()
			sprite.centered = false
			sprite.position = Vector2(-texture_size.x * 0.5, -texture_size.y)
	elif _visual is Polygon2D:
		(_visual as Polygon2D).color = visual_color
	# Restore depleted state if it was harvested earlier this day.
	if DaySystem.is_gatherable_depleted(gatherable_id):
		set_depleted(true)

func interact() -> void:
	if depleted:
		return
	Inventory.add_item(item_id, item_quantity)
	interacted.emit()
	set_depleted(true)
	DaySystem.set_gatherable_depleted(gatherable_id, true)
	print("Gathered %dx %s" % [item_quantity, item_id])

func show_prompt(value: bool) -> void:
	# Never prompt for an already-harvested node.
	super.show_prompt(value and not depleted)

func set_depleted(value: bool) -> void:
	depleted = value
	if _visual:
		_visual.modulate = Color(0.45, 0.45, 0.45, 0.5) if depleted else Color.WHITE
	if depleted:
		super.show_prompt(false)

func reset_for_new_day() -> void:
	if reset_daily:
		set_depleted(false)
