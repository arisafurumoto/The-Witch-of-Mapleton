extends "res://scripts/core/Interactable.gd"

# Sleeping fades out the current day, advances and saves while the screen is
# covered, then reveals the new day before returning control to the player.

func interact() -> void:
	if HUD.is_day_transition_active():
		return
	interacted.emit()
	AudioSystem.play_sleep()
	await HUD.fade_to_night()
	DaySystem.advance_day()
	SaveSystem.save_game()
	await HUD.reveal_new_day(DaySystem.get_day())
