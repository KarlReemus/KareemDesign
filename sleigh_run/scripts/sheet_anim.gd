extends Sprite2D

@export var fps := 12.0
@export var row := 0
@export var speed_scaled := true
var t := 0.0

func _process(delta: float) -> void:
	var mult := (Game.speed / Game.START_SPEED) if speed_scaled else 1.0
	t += delta * fps * mult
	frame_coords = Vector2i(int(t) % hframes, row)
