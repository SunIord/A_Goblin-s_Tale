extends Node2D
@export var gameui: CanvasLayer
@export var game_over_ui: PackedScene

func _ready():
	GameManager.game_over.connect(trigger_game_over)

func trigger_game_over():
	if gameui:
		gameui.queue_free()
		gameui = null
	var game_over:GameOver = game_over_ui.instantiate()
	game_over.monsters_defeated = 999
	game_over.time_survived = "01:58"
	add_child(game_over)
	
