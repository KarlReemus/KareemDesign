extends CanvasLayer

@onready var root: Control = %Root
@onready var score_label: Label = %ScoreLabel
@onready var mult_label: Label = %MultLabel
@onready var presents_label: Label = %PresentsLabel

func _ready() -> void:
	Game.presents_changed.connect(_on_presents)
	Game.combo_changed.connect(_on_combo)
	Game.state_changed.connect(func(s): root.visible = s != Game.State.TITLE)
	root.visible = Game.state != Game.State.TITLE
	_on_presents(Game.presents)
	_on_combo(Game.combo, Game.multiplier)

func _process(_d: float) -> void:
	score_label.text = str(int(Game.score))

func _on_presents(n: int) -> void:
	presents_label.text = "Presents %d/%d" % [n, Game.MAX_PRESENTS]

func _on_combo(combo: int, mult: float) -> void:
	mult_label.text = ("x%.1f" % mult) if combo > 0 else ""
	mult_label.pivot_offset = mult_label.size / 2
	var tw := create_tween()
	tw.tween_property(mult_label, "scale", Vector2(1.4, 1.4), 0.08)
	tw.tween_property(mult_label, "scale", Vector2.ONE, 0.12)
