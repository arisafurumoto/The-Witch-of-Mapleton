extends "res://scripts/core/Interactable.gd"

# One authored Moonleaf planter for slice 1.7.

@export var planter_id: String = PlanterSystem.DEFAULT_PLANTER_ID
@export var sprout_texture: Texture2D
@export var young_texture: Texture2D
@export var ready_texture: Texture2D
@export var harvested_texture: Texture2D

@onready var _growth_visual: Sprite2D = get_node_or_null("GrowthVisual") as Sprite2D

func _ready() -> void:
	super._ready()
	add_to_group("planters")
	DaySystem.day_changed.connect(_on_day_changed)
	PlanterSystem.planter_changed.connect(_on_planter_changed)
	_update_visual()

func interact() -> void:
	interacted.emit()
	var stage := PlanterSystem.get_stage(planter_id)
	if stage == PlanterSystem.STAGE_READY:
		_harvest()
		return
	if stage == PlanterSystem.STAGE_SPROUT or stage == PlanterSystem.STAGE_YOUNG:
		HUD.show_toast("Moonleaf is still growing")
		return
	_plant()

func show_prompt(value: bool) -> void:
	var stage := PlanterSystem.get_stage(planter_id)
	if stage == PlanterSystem.STAGE_READY:
		prompt = "Harvest Moonleaf"
	elif stage == PlanterSystem.STAGE_SPROUT or stage == PlanterSystem.STAGE_YOUNG:
		prompt = "Growing"
	else:
		prompt = "Plant Moonleaf"
	if _label:
		_label.text = prompt
	super.show_prompt(value)

func _plant() -> void:
	if not Inventory.has_item(PlanterSystem.SEED_ITEM_ID, 1):
		HUD.show_toast("Need Moonleaf Seed Packet")
		return
	if PlanterSystem.plant(planter_id):
		HUD.show_toast("Planted Moonleaf")
		_update_visual()

func _harvest() -> void:
	if PlanterSystem.harvest(planter_id):
		HUD.show_toast("Harvested Moonleaf x%d" % PlanterSystem.HARVEST_QUANTITY)
		_update_visual()

func _update_visual() -> void:
	if _growth_visual == null:
		return
	var stage := PlanterSystem.get_stage(planter_id)
	var next_texture: Texture2D = null
	if stage == PlanterSystem.STAGE_SPROUT:
		next_texture = sprout_texture
	elif stage == PlanterSystem.STAGE_YOUNG:
		next_texture = young_texture
	elif stage == PlanterSystem.STAGE_READY:
		next_texture = ready_texture
	elif stage == PlanterSystem.STAGE_HARVESTED:
		next_texture = harvested_texture
	_growth_visual.texture = next_texture
	_growth_visual.visible = next_texture != null

func _on_day_changed(_day: int) -> void:
	_update_visual()

func _on_planter_changed(changed_planter_id: String) -> void:
	if changed_planter_id == planter_id:
		_update_visual()
