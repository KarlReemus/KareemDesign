extends Node2D

@export var textures: Array[Texture2D] = []
@export var miss_x := 175.0          # chimney has passed the sleigh's drop point
var delivered := false
var missed := false
@onready var sprite: Sprite2D = $Sprite2D
@onready var chimney: Area2D = $Chimney

func _ready() -> void:
	add_to_group("cleanup")
	if textures.size() > 0:
		sprite.texture = textures.pick_random()

func _process(delta: float) -> void:
	if not Game.running:
		return
	position.x -= Game.speed * delta
	if not delivered and not missed and global_position.x < miss_x:
		missed = true
		Game.break_combo()
	if global_position.x < -300.0:
		queue_free()

func deliver() -> void:
	if delivered:
		return
	delivered = true
	var pts := Game.deliver_success()
	Sfx.play("deliver", 1.0 + minf(Game.combo, 12) * 0.05)
	var tw := create_tween()
	sprite.modulate = Color(1.35, 1.25, 0.8)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.5)
	var l := Label.new()
	l.text = "+%d" % pts
	l.add_theme_font_size_override("font_size", 40)
	l.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	l.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.2))
	l.add_theme_constant_override("outline_size", 10)
	l.position = Vector2(chimney.position.x - 30, -260)
	add_child(l)
	var tl := create_tween()
	tl.tween_property(l, "position:y", -340.0, 0.7)
	tl.parallel().tween_property(l, "modulate:a", 0.0, 0.7)
	tl.tween_callback(l.queue_free)
