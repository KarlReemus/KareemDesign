extends CanvasLayer

func _ready() -> void:
	visible = Game.running
	Game.state_changed.connect(func(s): visible = s == Game.State.PLAYING)
