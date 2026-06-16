extends "res://scripts/core/Interactable.gd"

# A door is an Interactable that loads another scene when used.

@export_file("*.tscn") var target_scene: String = ""
@export var use_target_player_position: bool = false
@export var target_player_position: Vector2 = Vector2.ZERO
@export var target_player_facing: String = ""

func interact() -> void:
	interacted.emit()
	if target_scene != "":
		if use_target_player_position:
			get_tree().root.set_meta("target_player_position", target_player_position)
		if target_player_facing != "":
			get_tree().root.set_meta("target_player_facing", target_player_facing)
		get_tree().change_scene_to_file(target_scene)
