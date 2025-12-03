extends Node2D
class_name MobSpawner

@export var creatures:Array[PackedScene]
@export var mobs_per_minute:float = 15.0

var spawn_enabled:bool = false
var cooldown:float = 0.0

@onready var path_follow_2d:PathFollow2D = %PathFollow2D


func _process(delta:float):
	if not spawn_enabled:
		return

	# Seguir player
	global_position = GameManager.player_position

	# Temporizador
	cooldown -= delta
	if cooldown > 0:
		return

	# Intervalo baseado em mobs_per_minute
	var interval = 60.0 / mobs_per_minute
	cooldown = interval

	_spawn_random_mob()


func _spawn_random_mob():
	if creatures.is_empty():
		return

	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	
	creature.global_position = get_point()
	get_parent().add_child(creature)


func get_point() -> Vector2:
	var base = GameManager.player_position

	path_follow_2d.progress_ratio = randf()
	var point = path_follow_2d.position

	var adjusted_point = point + Vector2(0, 10) 
	return adjusted_point + base


# ----------------------------------------------------------
# HORDE MANAGER API
# ----------------------------------------------------------

func start_spawning(rate:float):
	# taxa da horda
	# EXEMPLO: rate = 1.0 → 60 mobs/min
	# rate = 2.0 → 120 mobs/min etc.
	mobs_per_minute = 60.0 * rate

	spawn_enabled = true
	cooldown = 0.0
	print("Spawner ON — ", mobs_per_minute, " mobs/min.")


func stop_spawning():
	spawn_enabled = false
	print("Spawner OFF")


func set_spawn_enabled(value:bool):
	spawn_enabled = value


func spawn_tutorial_enemies():
	# opcional — coloque o que quiser aqui
	print("Spawning tutorial enemies...")
	# Exemplo: spawn 3 fracos
	for i in range(3):
		_spawn_random_mob()
