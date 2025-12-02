extends Node
signal game_over

var player_position: Vector2
var is_game_over: bool = false

var time_elapsed: float = 0.0
var death_count: int = 0
var gold_count: int = 0
var time_elapsed_string: String


func _process(delta: float):
	time_elapsed += delta
	var time_elapsed_second: int = floori(time_elapsed)
	var min: int
	var sec: int
	sec = time_elapsed_second % 60
	min = time_elapsed_second/60
	time_elapsed_string = "%02d:%02d" % [min,sec]
	

func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()

func reset():
	player_position = Vector2.ZERO
	is_game_over = false
	time_elapsed = 0.0
	death_count = 0
	gold_count = 0
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
	
