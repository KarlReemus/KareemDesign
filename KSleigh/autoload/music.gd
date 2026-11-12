extends Node

# Drop .ogg/.mp3 files into user://music (desktop) or ship them in res://assets/audio/music.
const BUILTIN_DIR := "res://assets/audio/music"
const USER_DIR := "user://music"
var tracks: Array[AudioStream] = []
var player := AudioStreamPlayer.new()
var index := -1

func _ready() -> void:
	player.bus = "Music"
	player.volume_db = -6.0
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
	next()

func next() -> void:
	if tracks.is_empty():
		return
	index = (index + 1) % tracks.size()
	player.stream = tracks[index]
	player.play()
