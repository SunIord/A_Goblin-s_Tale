class_name GameOver

extends CanvasLayer
@onready var time_label: Label = %Time_Label
@onready var monsters_label: Label = %Monsters_Label
@onready var dyingSfx = $dying_sfx as AudioStreamPlayer

@export var restart_delay: float = 5.0
var restart_cooldown: float
var time_survived: String
var monsters_defeated: int

func _ready():
	dyingSfx.play()
	time_label.text = GameManager.time_elapsed_string
	monsters_label.text = str(GameManager.death_count)
	restart_cooldown = restart_delay

func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()
func restart_game():
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/Areas/Hub.tscn")
