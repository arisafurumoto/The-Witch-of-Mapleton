extends Area2D

# Reusable interaction target. The player detects nearby Interactables and calls
# interact() on the nearest one when the interact action is pressed. Doors,
# gatherables, crafting stations, NPCs, etc. will build on this pattern.

signal interacted

@export var prompt: String = "Examine"
@export var speaker: String = ""
@export_multiline var dialogue: String = ""

@onready var _label: Label = get_node_or_null("PromptLabel")
@onready var _visual: CanvasItem = get_node_or_null("Visual")

func _ready() -> void:
	if _label:
		_label.text = prompt
		_label.visible = false

func show_prompt(value: bool) -> void:
	if _label:
		_label.visible = value

func interact() -> void:
	interacted.emit()
	var lines := _dialogue_lines()
	if not lines.is_empty():
		DialogueBox.show_dialogue(speaker, lines)
		return
	if _visual:
		var tween := create_tween()
		tween.tween_property(_visual, "modulate", Color(1.6, 1.6, 1.6, 1.0), 0.08)
		tween.tween_property(_visual, "modulate", Color(1, 1, 1, 1), 0.12)

func _dialogue_lines() -> Array:
	var text := dialogue.strip_edges()
	if text == "":
		return []
	return text.split("\n", false)
