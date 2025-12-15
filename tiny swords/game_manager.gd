extends Node

signal game_over
signal powerup_purchased(powerup_id: String)  # Novo sinal

# -------------------------------------------------
# PLAYER STATS (POWER-UPS BÁSICOS)
# -------------------------------------------------
var max_health: int = 100
var current_health: int = 100
var move_speed: float = 3.0
var base_damage: int = 2  # DANO BASE DO PLAYER

# -------------------------------------------------
# GAME STATE
# -------------------------------------------------
var player_position: Vector2
var is_game_over: bool = false
var time_remaining: float = 0.0
var death_count: int = 0
var gold_count: int = 0
var time_elapsed_string: String
var allow_timer := false
var horde_manager: Node = null
var current_level: int = 0
var horde: int = 1
var level1_cutscene_played: bool = false

# NOVO: Sistema de power-ups comprados
var purchased_powerups: Array[String] = []  # IDs dos power-ups comprados

# -------------------------------------------------
# POWER-UP SYSTEM
# -------------------------------------------------
func purchase_powerup(powerup_id: String):
	if not is_powerup_purchased(powerup_id):
		purchased_powerups.append(powerup_id)
		powerup_purchased.emit(powerup_id)
		print("Power-up comprado:", powerup_id)

func is_powerup_purchased(powerup_id: String) -> bool:
	return purchased_powerups.has(powerup_id)

# -------------------------------------------------
# HORDE / LEVEL
# -------------------------------------------------
func increase_horde():
	horde += 1

func complete_level():
	current_level += 1

func reset_horde():
	horde = 1

# -------------------------------------------------
# GAME FLOW
# -------------------------------------------------
func end_game():
	if is_game_over:
		return
	is_game_over = true
	allow_timer = false
	game_over.emit()

func reset():
	player_position = Vector2.ZERO
	is_game_over = false

	death_count = 0
	time_remaining = 0.0

	# reseta stats do player (MAS MANTÉM DANO UPGRADE!)
	current_health = max_health
	# NÃO reseta base_damage aqui - upgrades são permanentes

	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)

func reset_gold():
	gold_count = 0

# Sistema de progresso
var completed_arenas: Array[String] = []  # Ex: ["level_1", "level_2"]

# -------------------------------------------------
# ARENA PROGRESS SYSTEM
# -------------------------------------------------
func mark_arena_completed(arena_name: String):
	if not is_arena_completed(arena_name):
		completed_arenas.append(arena_name)
		print("Arena marcada como completada:", arena_name)

func is_arena_completed(arena_name: String) -> bool:
	return completed_arenas.has(arena_name)

func get_completed_arenas() -> Array[String]:
	return completed_arenas.duplicate()
