class_name GameOver

extends CanvasLayer
@onready var arena_label: Label = %Arena_Label
@onready var horde_label: Label = %Horde_Label
@onready var dyingSfx = $dying_sfx as AudioStreamPlayer

@export var restart_delay: float = 5.0
var restart_cooldown: float
var time_survived: String
var monsters_defeated: int

func get_arena_name(level: int) -> String:
	match level:
		1:
			return "O Fosso"
		2:
			return "A Ilha"
		3:
			return "O Deserto"
		_:
			return "??"

func _ready():
	dyingSfx.play()
	arena_label.text = get_arena_name(GameManager.current_level)
	horde_label.text = str(GameManager.horde)
	restart_cooldown = restart_delay

func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()
func restart_game():
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/Areas/Hub.tscn")
