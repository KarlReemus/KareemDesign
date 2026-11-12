extends Node2D

signal crashed
signal powerup_collected(kind)

@export var present_scene: PackedScene
@export var max_speed := 650.0
@export var lead_accel := 10.0
@export var follow_rate := 9.0
@export var y_min := 100.0
@export var y_max := 400.0
@export var start_y := 300.0

var velocity_y := 0.0
var drop_cooldown := 0.0
var segments: Array[Area2D] = []

func _ready() -> void:
	for c in get_children():
		segments.append(c)
		c.hit_obstacle.connect(func(): crashed.emit())
		c.got_powerup.connect(func(k): powerup_collected.emit(k))
	var lead_sprite := segments[0].get_node_or_null("Sprite2D")
	if lead_sprite and "row" in lead_sprite:
		lead_sprite.row = 1          # red-nose row of the sheet
	reset()

func reset() -> void:
	velocity_y = 0.0
	drop_cooldown = 0.0
	for s in segments:
		s.position.y = start_y
		s.rotation = 0.0

func _physics_process(delta: float) -> void:
	if not Game.running:
		return
	var dir := Input.get_axis("move_up", "move_down")
	velocity_y = lerpf(velocity_y, dir * max_speed, 1.0 - exp(-lead_accel * delta))
	var lead := segments[0]
	lead.position.y = clampf(lead.position.y + velocity_y * delta, y_min, y_max)
	lead.rotation = (velocity_y / max_speed) * 0.3
	var t := 1.0 - exp(-follow_rate * delta)
	for i in range(1, segments.size()):
		var ahead := segments[i - 1]
		var seg := segments[i]
		seg.position.y = lerpf(seg.position.y, ahead.position.y, t)
		seg.rotation = lerp_angle(seg.rotation, (ahead.position - seg.position).angle() * 0.6, t)
	drop_cooldown -= delta
	if Input.is_action_just_pressed("drop_present") and drop_cooldown <= 0.0 and Game.use_present():
		var p := present_scene.instantiate()
		p.global_position = segments.back().global_position + Vector2(0, 50)
		get_parent().add_child(p)
		drop_cooldown = 0.25
		Sfx.play("drop")
