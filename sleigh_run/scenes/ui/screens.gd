extends CanvasLayer

@onready var title: Control = %Title
@onready var over: Control = %GameOver
@onready var final_label: Label = %FinalScore
@onready var play_button: Button = %PlayButton
@onready var retry_button: Button = %RetryButton

func _ready() -> void:
	play_button.pressed.connect(Game.start)
	retry_button.pressed.connect(Game.start)
	Game.state_changed.connect(_on_state)
	_on_state(Game.state)

func _on_state(s) -> void:
	title.visible = s == Game.State.TITLE
	over.visible = s == Game.State.GAME_OVER
	if s == Game.State.GAME_OVER:
		final_label.text = "Score %d\nBest %d" % [int(Game.score), Game.high_score]
		retry_button.grab_focus()
	elif s == Game.State.TITLE:
		play_button.grab_focus()
