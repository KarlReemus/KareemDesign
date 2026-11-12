extends Area2D

signal hit_obstacle
signal got_powerup(kind)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(a: Area2D) -> void:
	if a.is_in_group("obstacle"):
		hit_obstacle.emit()
	elif a.is_in_group("powerup"):
		got_powerup.emit(a.kind)
		a.queue_free()
