extends Node

var sounds := {}

func _ready() -> void:
	for n in ["pickup", "drop", "deliver", "crash"]:
		for ext in ["wav", "ogg"]:
			var p := "res://assets/audio/sfx/%s.%s" % [n, ext]
			if ResourceLoader.exists(p):
				sounds[n] = load(p)
				break

func play(sound_name: String, pitch := 1.0) -> void:
	if not sounds.has(sound_name):
		return
	var pl := AudioStreamPlayer.new()
	pl.stream = sounds[sound_name]
	pl.pitch_scale = pitch
	pl.bus = "SFX"
	add_child(pl)
	pl.finished.connect(pl.queue_free)
	pl.play()
