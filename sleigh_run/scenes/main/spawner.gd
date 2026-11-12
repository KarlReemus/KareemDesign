extends Node2D

@export var obstacles: Array[PackedScene]
@export var pickups: Array[PackedScene]
var cooldown := 1.5

func _ready() -> void:
	Game.state_changed.connect(func(s): cooldown = 1.5)

func _process(delta: float) -> void:
	if not Game.running:
		return
	cooldown -= delta
	if cooldown <= 0.0:
		_spawn()
		cooldown = randf_range(0.9, 1.6) * (Game.START_SPEED / Game.speed)

func _spawn() -> void:
	var pool := pickups if randf() < 0.3 else obstacles
	var n: Node2D = pool.pick_random().instantiate()
	n.position = Vector2(get_viewport_rect().size.x + 200.0, randf_range(110.0, 440.0))
	add_child(n)
