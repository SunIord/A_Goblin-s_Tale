extends Node2D

@onready var gameui = $GameUI
@export var game_over_ui: PackedScene	

func _ready():
	# conecta o player quando ele já existir
	GameManager.game_over.connect(trigger_game_over)
	MusicPlayer.stop()
	var player = $player
	connect_player_restart(player)

func trigger_game_over():
	if gameui:
		gameui.queue_free()
		gameui = null
	var game_over:GameOver = game_over_ui.instantiate()
	game_over.monsters_defeated = 999
	game_over.time_survived = "01:58"
	add_child(game_over)
	
func connect_player_restart(player):
	# encontra todos os ataques do player e conecta o signal
	for attack in player.get_children():
		if attack is Area2D and attack.has_signal("request_restart"):
			attack.connect("request_restart", _on_restart_requested)

func _on_restart_requested():
	if gameui.has_method("restart"):
		gameui.restart()
