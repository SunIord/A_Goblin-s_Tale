extends Node2D
@export var gameui: CanvasLayer
@export var game_over_ui: PackedScene
const CutsceneIntroScene := preload("res://scenes/cutscene/Cutscene.tscn")

@onready var cutscene_layer: CanvasLayer = $CutsceneLayer
@onready var buttonSfx = $click_button as AudioStreamPlayer

func _ready():
	_show_cutscene_intro()
	GameManager.game_over.connect(trigger_game_over)

func _show_cutscene_intro() -> void:
	var cutscene := CutsceneIntroScene.instantiate()
	cutscene_layer.add_child(cutscene)

func trigger_game_over():
	if gameui:
		gameui.queue_free()
		gameui = null
	var game_over:GameOver = game_over_ui.instantiate()
	game_over.monsters_defeated = 999
	game_over.time_survived = "01:58"
	add_child(game_over)
	
