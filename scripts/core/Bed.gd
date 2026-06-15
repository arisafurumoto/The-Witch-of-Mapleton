extends "res://scripts/core/Interactable.gd"

# Sleeping in the bed ends the day: advance the day (refilling gatherables),
# save the game, then show a short confirmation.

func interact() -> void:
	interacted.emit()
	DaySystem.advance_day()
	SaveSystem.save_game()
	DialogueBox.show_dialogue("", [
		"You tuck in for the night...",
		"A new day begins. Day %d." % DaySystem.get_day(),
	])
