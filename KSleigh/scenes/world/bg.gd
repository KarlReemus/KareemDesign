extends ParallaxBackground

func _process(delta: float) -> void:
	scroll_offset.x -= (Game.speed if Game.running else 60.0) * delta
