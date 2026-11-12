extends Node

# Loads music from res://assets/audio/music (ships with the game) and user://music (desktop testing),
# and starts it automatically. Browsers refuse to play any sound before the player's first tap, click
# or key press, so on the web the music (re)starts cleanly on that first gesture. Sound effects use
# the same unlocked audio, so they work from that moment on too.
const BUILTIN_DIR := "res://assets/audio/music"
const USER_DIR := "user://music"
const MUSIC_DB := -6.0
const FADE_IN := 1.0

var tracks: Array[AudioStream] = []
var player := AudioStreamPlayer.new()
var index := 0
var unlocked := not OS.has_feature("web")
var fade: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player.bus = "Music"
	player.volume_db = MUSIC_DB
	add_child(player)
	player.finished.connect(next)
	DirAccess.make_dir_recursive_absolute(USER_DIR)
	for f in DirAccess.get_files_at(BUILTIN_DIR):
		var fname := f.trim_suffix(".import").trim_suffix(".remap")
		if fname.get_extension().to_lower() in ["ogg", "mp3", "wav"]:
			var s = load(BUILTIN_DIR + "/" + fname)
			if s is AudioStream and not tracks.has(s):
				tracks.append(s)
	for f in DirAccess.get_files_at(USER_DIR):
		var path := USER_DIR + "/" + f
		match f.get_extension().to_lower():
			"ogg":
				var ogg := AudioStreamOggVorbis.load_from_file(path)
				if ogg:
					tracks.append(ogg)
			"mp3":
				var mp3 := AudioStreamMP3.new()
				mp3.data = FileAccess.get_file_as_bytes(path)
				tracks.append(mp3)
	tracks.shuffle()
	_play_current()          # autoplay (on the web it only becomes audible after the first gesture)

# First tap, click or key press unlocks browser audio: restart the track so it begins at 0:00.
func _input(event: InputEvent) -> void:
	if unlocked:
		return
	if (event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey) and event.is_pressed():
		unlocked = true
		_play_current()

func next() -> void:
	if tracks.is_empty():
		return
	index = (index + 1) % tracks.size()
	_play_current()

func _play_current() -> void:
	if tracks.is_empty():
		return
	player.stream = tracks[index]
	player.volume_db = -40.0
	player.play()
	if fade and fade.is_valid():
		fade.kill()
	fade = create_tween()
	fade.tween_property(player, "volume_db", MUSIC_DB, FADE_IN)

# Pause the music while the window or tab is in the background.
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			player.stream_paused = true
		NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_WM_WINDOW_FOCUS_IN:
			player.stream_paused = false
