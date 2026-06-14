extends "res://scripts/core/Interactable.gd"

# A door is an Interactable that loads another scene when used.

@export_file("*.tscn") var target_scene: String = ""

func interact() -> void:
	interacted.emit()
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
