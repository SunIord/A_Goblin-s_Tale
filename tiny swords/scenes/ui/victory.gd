class_name VictoryScreen
extends CanvasLayer

@onready var arena_label: Label = %Arena_Label
@onready var horde_label: Label = %Horde_Label
# @onready var victorySfx = $victory_sfx as AudioStreamPlayer
# https://www.youtube.com/watch?v=B6njtbldrjc

@export var return_delay: float = 3.0
var return_cooldown: float

var arena_names = {
	"level_1": "O Fosso",
	"level_2": "A Ilha", 
	"level_3": "O Deserto"  # Para quando criar
}

func get_arena_name() -> String:
	var scene_name = get_tree().current_scene.name
	
	# Converte para minúsculo para garantir match
	scene_name = scene_name.to_lower()
	
	if arena_names.has(scene_name):
		return arena_names[scene_name]
	else:
		# Extrai o número da cena (level_X)
		if scene_name.begins_with("level_"):
			var number = scene_name.substr(6)  # Pega tudo depois de "level_"
			return "Arena " + number
		return scene_name

func _ready():
	#victorySfx.play()
	arena_label.text = get_arena_name()
	horde_label.text = " " % GameManager.horde
	return_cooldown = return_delay

func _process(delta):
	return_cooldown -= delta
	if return_cooldown <= 0.0:
		return_to_hub()

func return_to_hub():
	# Marca a arena atual como completada
	var current_scene = get_tree().current_scene.name.to_lower()  # "level_1", "level_2", etc.
	GameManager.mark_arena_completed(current_scene)
	
	# Volta para o hub
	get_tree().change_scene_to_file("res://scenes/Areas/Hub.tscn")
