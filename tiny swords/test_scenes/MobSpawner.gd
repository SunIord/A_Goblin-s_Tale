extends Node2D

@export var creatures:Array[PackedScene]
@export var mobs_per_minute:float = 15.0

@onready var path_follow_2d:PathFollow2D = %PathFollow2D
var cooldown:float = 0.0

func _process(delta:float):
	# Temporizador
	global_position = GameManager.player_position
	cooldown -= delta
	if cooldown > 0:
		return
	
	# Frequência
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	# Instanciar um mob
	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = get_point()
	get_parent().add_child(creature)

func get_point() -> Vector2:
	# Usar a posição local do PathFollow2D em vez da global
	var base = GameManager.player_position
	path_follow_2d.progress_ratio = randf()
	var point = path_follow_2d.position  # posição local, sem o offset global
	
	# Ajuste de altura se necessário (dependendo da sua cena, talvez seja necessário um pequeno ajuste manual)
	var adjusted_point = point + Vector2(0, 10)  # Ajuste de Y para corrigir a altura, se necessário

	# Log para depuração
	print("Ponto gerado: ", adjusted_point)  # Log da posição ajustada para verificação
	return adjusted_point + base
