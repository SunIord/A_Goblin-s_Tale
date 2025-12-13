extends Node2D
class_name MobSpawner

@export var mobs_per_minute:float = 15.0

var spawn_enabled:bool = false
var cooldown:float = 0.0
var creatures: Array[CreatureSpawnConfig] = []

@onready var path_follow_2d:PathFollow2D = %PathFollow2D


func _process(delta:float):
	if not spawn_enabled:
		return

	global_position = GameManager.player_position

	cooldown -= delta
	if cooldown > 0:
		return

	var interval = 60.0 / mobs_per_minute
	cooldown = interval

	_spawn_random_mob()


func _spawn_random_mob():
	if creatures.is_empty():
		return

	var total_weight := 0.0
	for cfg in creatures:
		total_weight += cfg.weight

	var r := randf() * total_weight
	var acc := 0.0

	for cfg in creatures:
		acc += cfg.weight
		if r <= acc:
			var creature = cfg.creature.instantiate()
			creature.global_position = get_point()
			get_parent().add_child(creature)
			return


func get_point() -> Vector2:
	var base = GameManager.player_position

	path_follow_2d.progress_ratio = randf()
	var point = path_follow_2d.position

	var adjusted_point = point + Vector2(0, 10) 
	return adjusted_point + base

func set_creatures(list: Array[CreatureSpawnConfig]) -> void:
	creatures = list

func start_spawning(rate:float):
	mobs_per_minute = 30.0 * rate

	spawn_enabled = true
	cooldown = 0.0
	print("Spawner ON — ", mobs_per_minute, " mobs/min.")


func stop_spawning():
	spawn_enabled = false
	print("Spawner OFF")


func set_spawn_enabled(value:bool):
	spawn_enabled = value

func _kill_all_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")

	for e in enemies:
		if e.is_inside_tree():
			if e.has_method("die"):
				e.die()
			else:
				e.queue_free()
