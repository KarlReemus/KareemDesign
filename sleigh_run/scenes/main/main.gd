extends Node2D

@onready var train: Node2D = $Train

func _ready() -> void:
	train.crashed.connect(_on_crash)
	train.powerup_collected.connect(_on_powerup)
	Game.state_changed.connect(_on_state)

func _on_crash() -> void:
	if Game.running:
		Sfx.play("crash")
		Game.end()

func _on_powerup(kind: String) -> void:
	match kind:
		"present":
			Game.add_present()
			Sfx.play("pickup")

func _on_state(s) -> void:
	if s == Game.State.PLAYING:
		get_tree().call_group("cleanup", "queue_free")   # clear leftovers on restart
		train.reset()
