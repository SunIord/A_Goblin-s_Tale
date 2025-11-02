extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var options_button = $VBoxContainer/OptionButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	# Troca para a cena principal do jogo
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_options_pressed():
	# (Exemplo) Abre um menu de opções ou uma nova cena
	get_tree().change_scene_to_file("res://scenes/main_menu/Options.tscn")

func _on_quit_pressed():
	get_tree().quit()
