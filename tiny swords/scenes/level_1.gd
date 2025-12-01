extends Node2D

@onready var gameui = $GameUI

func _ready():
	# conecta o player quando ele já existir
	MusicPlayer.stop()
	var player = $player
	connect_player_restart(player)

func connect_player_restart(player):
	# encontra todos os ataques do player e conecta o signal
	for attack in player.get_children():
		if attack is Area2D and attack.has_signal("request_restart"):
			attack.connect("request_restart", _on_restart_requested)

func _on_restart_requested():
	if gameui.has_method("restart"):
		gameui.restart()
