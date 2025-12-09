extends Node
signal game_over

var player_position: Vector2
var is_game_over: bool = false
var time_remaining: float = 0.0
var death_count: int = 0
var gold_count: int = 0
var time_elapsed_string: String
var allow_timer: = false
var horde_manager: Node = null
var current_level: int = 0
var horde: int = 1

func increase_horde():
	horde += 1

func complete_level():
	current_level += 1

func reset_horde():
	horde = 1

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
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
		
func reset_gold():
	gold_count = 0
