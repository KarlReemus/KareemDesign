extends Area2D

const GRAVITY := 1400.0
const GROUND_Y := 700.0
var vel_y := 0.0

func _ready() -> void:
	add_to_group("cleanup")
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if not Game.running:
		return
	vel_y += GRAVITY * delta
	position.y += vel_y * delta
	rotation += 3.0 * delta
	if position.y > GROUND_Y:
		Game.break_combo()          # missed: hit the ground without finding a chimney
		queue_free()

func _on_area_entered(a: Area2D) -> void:
	if a.is_in_group("chimney"):
		a.get_parent().deliver()
		queue_free()
