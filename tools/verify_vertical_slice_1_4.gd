extends SceneTree

const DIALOGUE_SCENE := "res://scenes/ui/DialogueBox.tscn"
const MARIGOLD_PORTRAIT := "res://art/characters/marigold/portraits/default.png"
const MARIGOLD_THINKING_PORTRAIT := "res://art/characters/marigold/portraits/thinking.png"
const SAGE_PORTRAIT := "res://art/characters/npcs/sage/portraits/default.png"
const SAGE_CONCERNED_PORTRAIT := "res://art/characters/npcs/sage/portraits/concerned.png"
const CAMELLIA_PORTRAIT := "res://art/characters/npcs/camellia/portraits/default.png"
const CAMELLIA_LAUGH_PORTRAIT := "res://art/characters/npcs/camellia/portraits/laugh.png"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_scene_wiring()
	await _check_portrait_lookup_and_fallback()
	await _check_dialogue_advance_still_works()
	if _failures.is_empty():
		print("Vertical Slice 1.4 verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _check_scene_wiring() -> void:
	_check(ResourceLoader.exists(DIALOGUE_SCENE), "DialogueBox.tscn does not exist")
	var dialogue: Node = root.get_node("DialogueBox")
	_check(dialogue.has_node("PortraitTexture"), "DialogueBox is missing the large PortraitTexture")
	_check(dialogue.has_node("NamePlate/Margin/NamePlateLabel"), "DialogueBox is missing the portrait name plate")
	_check(dialogue.has_node("Panel/Margin/VBox/NameLabel"), "DialogueBox name label moved unexpectedly")
	_check(dialogue.has_node("Panel/Margin/VBox/LineLabel"), "DialogueBox line label moved unexpectedly")

	var portrait_texture := dialogue.get_node("PortraitTexture") as TextureRect
	var name_plate := dialogue.get_node("NamePlate") as Control
	_check(portrait_texture.size == Vector2(150, 150), "Large portrait texture size is not stable")
	_check(name_plate.offset_left == 8.0 and name_plate.offset_right == 150.0, "Portrait name plate horizontal offsets are not stable")
	_check(name_plate.offset_top == 324.0 and name_plate.offset_bottom == 352.0, "Portrait name plate vertical offsets are not stable")
	_check(portrait_texture.expand_mode == TextureRect.EXPAND_IGNORE_SIZE, "Portrait texture expand mode is incorrect")
	_check(portrait_texture.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Portrait texture stretch mode is incorrect")

	for path in [MARIGOLD_PORTRAIT, MARIGOLD_THINKING_PORTRAIT, SAGE_PORTRAIT, SAGE_CONCERNED_PORTRAIT, CAMELLIA_PORTRAIT, CAMELLIA_LAUGH_PORTRAIT]:
		_check(FileAccess.file_exists(String(path)), "Portrait source file is missing: " + String(path))
		_check(ResourceLoader.exists(String(path)), "Portrait resource is not imported: " + String(path))

func _check_portrait_lookup_and_fallback() -> void:
	var dialogue: Node = root.get_node("DialogueBox")
	_check(String(dialogue.call("get_portrait_path_for_speaker", "Marigold")) == MARIGOLD_PORTRAIT, "Marigold portrait lookup is incorrect")
	_check(String(dialogue.call("get_portrait_path_for_speaker", "Marigold", "thinking")) == MARIGOLD_THINKING_PORTRAIT, "Marigold thinking portrait lookup is incorrect")
	_check(String(dialogue.call("get_portrait_path_for_speaker", "Sage")) == SAGE_PORTRAIT, "Sage portrait lookup is incorrect")
	_check(String(dialogue.call("get_portrait_path_for_speaker", "Sage", "concerned")) == SAGE_CONCERNED_PORTRAIT, "Sage concerned portrait lookup is incorrect")
	_check(String(dialogue.call("get_portrait_path_for_speaker", "Camellia")) == CAMELLIA_PORTRAIT, "Camellia portrait lookup is incorrect")
	_check(String(dialogue.call("get_portrait_path_for_speaker", "Camellia", "laugh")) == CAMELLIA_LAUGH_PORTRAIT, "Camellia laugh portrait lookup is incorrect")
	_check(String(dialogue.call("get_portrait_path_for_speaker", "Camellia", "missing_expression")) == CAMELLIA_PORTRAIT, "Camellia missing expression should fall back to default")
	_check(String(dialogue.call("get_portrait_path_for_speaker", "Notice Board")) == "", "Notice Board should not have a portrait")
	_check(String(dialogue.call("get_portrait_path_for_speaker", "Villager")) == "", "Villager should use the no-portrait fallback")

	dialogue.call("show_dialogue", "Sage", [{"speaker": "Sage", "expression": "concerned", "text": "The seedlings are patient today."}])
	await process_frame
	_check(bool(dialogue.call("is_active")), "Dialogue did not open for Sage")
	_check(bool(dialogue.call("is_portrait_visible")), "Sage dialogue did not show a portrait")
	_check(String(dialogue.call("get_current_portrait_path")) == SAGE_CONCERNED_PORTRAIT, "Sage current expression portrait path is incorrect")
	var portrait_texture := dialogue.get_node("PortraitTexture") as TextureRect
	var name_plate := dialogue.get_node("NamePlate") as Control
	var name_plate_label := dialogue.get_node("NamePlate/Margin/NamePlateLabel") as Label
	var panel := dialogue.get_node("Panel") as Control
	var name_label := dialogue.get_node("Panel/Margin/VBox/NameLabel") as Label
	_check(portrait_texture.texture != null, "Sage portrait texture did not load")
	_check(name_plate.visible, "Sage dialogue did not show the portrait name plate")
	_check(name_plate_label.text == "Sage", "Sage name plate text is incorrect")
	_check(not name_label.visible, "Inline name label should hide when portrait name plate is visible")
	_check(panel.offset_left == 154.0, "Dialogue panel did not shift right for a portrait speaker")
	_check(panel.offset_right == -8.0, "Dialogue panel right edge is wrong for a left portrait speaker")
	_check(portrait_texture.offset_left == 4.0 and portrait_texture.offset_right == 154.0, "Sage portrait is not on the left")
	_check(name_plate.offset_left == 8.0 and name_plate.offset_right == 150.0, "Sage name plate is not on the left")
	dialogue.call("_advance")
	await process_frame

	dialogue.call("show_dialogue", "Camellia", ["Fresh tea changes the room."])
	await process_frame
	_check(bool(dialogue.call("is_portrait_visible")), "Camellia dialogue did not show a portrait")
	_check(String(dialogue.call("get_current_portrait_path")) == CAMELLIA_PORTRAIT, "Camellia current portrait path is incorrect")
	dialogue.call("_advance")
	await process_frame

	dialogue.call("show_dialogue", "Marigold", [{"speaker": "Marigold", "expression": "thinking", "text": "The path is still tangled with sleepy roots."}])
	await process_frame
	_check(bool(dialogue.call("is_portrait_visible")), "Marigold dialogue did not show a portrait")
	_check(String(dialogue.call("get_current_portrait_path")) == MARIGOLD_THINKING_PORTRAIT, "Marigold current expression portrait path is incorrect")
	_check(panel.offset_left == 8.0, "Dialogue panel left edge is wrong for Marigold's right portrait")
	_check(panel.offset_right == -154.0, "Dialogue panel did not shift left for Marigold's right portrait")
	_check(portrait_texture.offset_left == 486.0 and portrait_texture.offset_right == 636.0, "Marigold portrait is not on the right")
	_check(name_plate.offset_left == 490.0 and name_plate.offset_right == 632.0, "Marigold name plate is not on the right")
	dialogue.call("_advance")
	await process_frame

	dialogue.call("show_dialogue", "Notice Board", ["There are no requests today."])
	await process_frame
	_check(not bool(dialogue.call("is_portrait_visible")), "Notice Board dialogue should hide the portrait slot")
	_check(String(dialogue.call("get_current_portrait_path")) == "", "Notice Board current portrait path should be empty")
	_check(not name_plate.visible, "Notice Board dialogue should hide the portrait name plate")
	_check(name_label.visible, "Notice Board dialogue should show the inline speaker label")
	_check(panel.offset_left == 8.0, "Dialogue panel did not expand left for a no-portrait speaker")
	dialogue.call("_advance")
	await process_frame

	dialogue.call("show_dialogue", "Villager", ["I will take the tea, please."])
	await process_frame
	_check(not bool(dialogue.call("is_portrait_visible")), "Villager dialogue should hide the portrait slot")
	_check(String(dialogue.call("get_current_portrait_path")) == "", "Villager current portrait path should be empty")
	dialogue.call("_advance")
	await process_frame

func _check_dialogue_advance_still_works() -> void:
	var dialogue: Node = root.get_node("DialogueBox")
	dialogue.call("show_dialogue", "Sage", [
		{"speaker": "Sage", "expression": "concerned", "text": "Line one."},
		{"speaker": "Marigold", "expression": "thinking", "text": "Line two."},
	])
	await process_frame
	_check(bool(dialogue.call("is_active")), "Dialogue did not open for advance test")
	var line_label := dialogue.get_node("Panel/Margin/VBox/LineLabel") as Label
	var name_plate_label := dialogue.get_node("NamePlate/Margin/NamePlateLabel") as Label
	_check(line_label.text == "Line one.", "Dialogue did not show the first line")
	_check(name_plate_label.text == "Sage", "Dialogue did not show Sage for the first speaker")
	_check(String(dialogue.call("get_current_portrait_path")) == SAGE_CONCERNED_PORTRAIT, "Dialogue did not use Sage's expression portrait")
	dialogue.call("_advance")
	await process_frame
	_check(bool(dialogue.call("is_active")), "Dialogue closed before the second line")
	_check(line_label.text == "Line two.", "Dialogue did not advance to the second line")
	_check(name_plate_label.text == "Marigold", "Dialogue did not switch to Marigold for the second speaker")
	_check(String(dialogue.call("get_current_portrait_path")) == MARIGOLD_THINKING_PORTRAIT, "Dialogue did not switch to Marigold's expression portrait")
	var panel := dialogue.get_node("Panel") as Control
	var portrait_texture := dialogue.get_node("PortraitTexture") as TextureRect
	var name_plate := dialogue.get_node("NamePlate") as Control
	_check(panel.offset_right == -154.0, "Dialogue panel did not leave room for Marigold on the right")
	_check(portrait_texture.offset_left == 486.0, "Dialogue did not move Marigold portrait to the right during speaker switch")
	dialogue.call("_advance")
	await process_frame
	_check(not bool(dialogue.call("is_active")), "Dialogue did not close after the final line")
	_check(not bool(dialogue.call("is_portrait_visible")), "Portrait did not hide after dialogue closed")
	_check(not name_plate.visible, "Name plate did not hide after dialogue closed")
	_check(String(dialogue.call("get_current_portrait_path")) == "", "Portrait path did not clear after dialogue closed")

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
