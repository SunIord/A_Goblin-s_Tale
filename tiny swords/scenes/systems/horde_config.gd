@tool
class_name HordeConfig
extends Resource

enum HordeType {
	TUTORIAL,
	KILL_COUNT,
	SURVIVE_TIME
}

@export var horde_type : HordeType
@export var enemy_amount : int = 0
@export var survive_time : float = 0.0
@export var spawn_rate : float = 1.0
