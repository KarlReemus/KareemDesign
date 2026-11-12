extends Node

signal presents_changed(count)
signal combo_changed(combo, mult)
signal state_changed(state)

enum State { TITLE, PLAYING, GAME_OVER }
const START_SPEED := 420.0
const MAX_SPEED := 950.0
const MAX_PRESENTS := 10
const MAX_MULT := 8.0

var state := State.TITLE
var speed := START_SPEED
var score := 0.0
var high_score := 0
var presents := 0
var combo := 0
var multiplier := 1.0
var running: bool:
	get:
		return state == State.PLAYING

func _ready() -> void:
	_setup_input()
	ensure_bus("Music")
	ensure_bus("SFX")
	var cfg := ConfigFile.new()
	if cfg.load("user://save.cfg") == OK:
		high_score = cfg.get_value("game", "high_score", 0)

# Input actions are created here so the project works even if the Input Map is empty.
func _setup_input() -> void:
	var keys := {
		"move_up": [KEY_UP, KEY_W],
		"move_down": [KEY_DOWN, KEY_S],
		"drop_present": [KEY_SPACE],
	}
	for action in keys:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for k in keys[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = k
			InputMap.action_add_event(action, ev)

func ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var i := AudioServer.bus_count - 1
	AudioServer.set_bus_name(i, bus_name)
	AudioServer.set_bus_send(i, "Master")

func _process(delta: float) -> void:
	if not running:
		return
	speed = minf(speed + 6.0 * delta, MAX_SPEED)
	score += speed * delta * 0.01 * multiplier

func start() -> void:
	speed = START_SPEED
	score = 0.0
	presents = 0
	combo = 0
	multiplier = 1.0
	state = State.PLAYING
	presents_changed.emit(presents)
	combo_changed.emit(combo, multiplier)
	state_changed.emit(state)

func end() -> void:
	if state != State.PLAYING:
		return
	break_combo()
	state = State.GAME_OVER
	if int(score) > high_score:
		high_score = int(score)
		var cfg := ConfigFile.new()
		cfg.set_value("game", "high_score", high_score)
		cfg.save("user://save.cfg")
	state_changed.emit(state)

func add_present(n := 1) -> void:
	presents = mini(presents + n, MAX_PRESENTS)
	presents_changed.emit(presents)

func use_present() -> bool:
	if presents <= 0:
		return false
	presents -= 1
	presents_changed.emit(presents)
	return true

func deliver_success() -> int:
	combo += 1
	multiplier = minf(1.0 + combo * 0.5, MAX_MULT)
	var pts := int(100.0 * multiplier)
	score += pts
	combo_changed.emit(combo, multiplier)
	return pts

func break_combo() -> void:
	if combo == 0:
		return
	combo = 0
	multiplier = 1.0
	combo_changed.emit(combo, multiplier)
