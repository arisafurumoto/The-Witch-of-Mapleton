extends Node

# Tiny gameplay audio helper. Keeps sound triggering simple for the vertical slice.

const GATHER_SOUND_PATH: String = "res://audio/sfx/gather.wav"
const CRAFT_SOUND_PATH: String = "res://audio/sfx/craft.wav"
const SALE_SOUND_PATH: String = "res://audio/sfx/sale.wav"
const SLEEP_SOUND_PATH: String = "res://audio/sfx/sleep.wav"

var _players: Array[AudioStreamPlayer] = []
var _volume_db: float = -10.0
var _gather_sound: AudioStream
var _craft_sound: AudioStream
var _sale_sound: AudioStream
var _sleep_sound: AudioStream

func _ready() -> void:
	_gather_sound = _load_sound(GATHER_SOUND_PATH)
	_craft_sound = _load_sound(CRAFT_SOUND_PATH)
	_sale_sound = _load_sound(SALE_SOUND_PATH)
	_sleep_sound = _load_sound(SLEEP_SOUND_PATH)

func play_gather() -> void:
	_play(_gather_sound)

func play_craft() -> void:
	_play(_craft_sound)

func play_sale() -> void:
	_play(_sale_sound)

func play_sleep() -> void:
	_play(_sleep_sound)

func _play(stream: AudioStream) -> void:
	if stream == null:
		return
	var player: AudioStreamPlayer = _get_available_player()
	player.stream = stream
	player.volume_db = _volume_db
	player.play()

func _load_sound(path: String) -> AudioStream:
	var resource: Resource = load(path)
	if resource is AudioStream:
		return resource as AudioStream
	push_warning("Could not load sound: " + path)
	return null

func _get_available_player() -> AudioStreamPlayer:
	var index: int = 0
	while index < _players.size():
		var player: AudioStreamPlayer = _players[index]
		if not player.playing:
			return player
		index += 1
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(new_player)
	_players.append(new_player)
	return new_player
