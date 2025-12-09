extends Node2D

@onready var gameui = $GameUI
@export var game_over_ui: PackedScene	
@onready var sfx = $music as AudioStreamPlayer
@onready var horde_manager = $HordeManager

func _ready():
	GameManager.complete_level(0)
	GameManager.game_over.connect(trigger_game_over)
	GameManager.allow_timer = true
	MusicPlayer.stop()
	sfx.play()
	
	if horde_manager:
		print("Level pronto — iniciando hordas.")
		horde_manager.show_horde_message_and_start()
	else:
		print("ERRO: HordeManager NÃO encontrado!")

func trigger_game_over():
	if gameui:
		gameui.queue_free()
		gameui = null

	var game_over:GameOver = game_over_ui.instantiate()

	game_over.monsters_defeated = 999
	game_over.time_survived = "01:58"

	add_child(game_over)
