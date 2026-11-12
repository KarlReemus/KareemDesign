extends Node2D

@export var houses: Array[PackedScene]
var cooldown := 2.0

func _ready() -> void:
	Game.state_changed.connect(func(s): cooldown = 2.0)

func _process(delta: float) -> void:
	if not Game.running:
		return
	cooldown -= delta
	if cooldown <= 0.0:
		var h: Node2D = houses.pick_random().instantiate()
		h.position = Vector2(get_viewport_rect().size.x + 250.0, 690.0)
		add_child(h)
		cooldown = randf_range(2.0, 3.5) * (Game.START_SPEED / Game.speed)
