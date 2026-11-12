extends Area2D

@export var kind := ""
@export var bob := 0.0
var base_y := 0.0
var t := 0.0

func _ready() -> void:
	add_to_group("cleanup")
	base_y = position.y
	t = randf() * TAU

func _process(delta: float) -> void:
	if not Game.running:
		return
	position.x -= Game.speed * delta
	if bob != 0.0:
		t += delta * 3.0
		position.y = base_y + sin(t) * bob
	if position.x < -300.0:
		queue_free()
