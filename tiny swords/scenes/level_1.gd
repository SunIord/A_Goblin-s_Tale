extends Node2D

@onready var gameui = $GameUI
@export var game_over_ui: PackedScene
@export var victory_ui: PackedScene 
@onready var sfx = $music as AudioStreamPlayer
@onready var horde_manager = $HordeManager
@onready var camera = $player/Camera2D
@onready var player = $player
@onready var intro_end = $CutsceneEndPoint

# Variável para controle do loop
var is_music_looping: bool = true


func _ready():
	var targets: Array[Vector2] = [
		intro_end.global_position
	]
	GameManager.complete_level()
	GameManager.game_over.connect(trigger_game_over)
	
	horde_manager.arena_completed.connect(trigger_victory)

	MusicPlayer.stop()
	
	# CONEXÃO DO SINAL PARA LOOP
	sfx.connect("finished", Callable(self, "_on_music_finished"))
	sfx.play()

	if not GameManager.level1_cutscene_played:
		start_intro_cutscene(targets)
	else:
		start_gameplay()


# --------------------------------------------------
# MÚSICA - LOOP COM VERIFICAÇÃO
# --------------------------------------------------
func _on_music_finished():
	# Reinicia a música apenas se ainda estiver em loop
	if is_music_looping and is_inside_tree():
		sfx.play()


# --------------------------------------------------
# CAMERA
# --------------------------------------------------
func zoom_camera(target_zoom: Vector2, duration: float):
	var tween = create_tween()
	tween.tween_property(camera, "zoom", target_zoom, duration)


# --------------------------------------------------
# CUTSCENE
# --------------------------------------------------
func start_intro_cutscene(targets: Array[Vector2]) -> void:
	GameManager.level1_cutscene_played = true

	# Travar sistemas
	GameManager.allow_timer = false
	player.start_cutscene(targets)

	if horde_manager:
		horde_manager.active = false
		
	if gameui:
		gameui.hide_all()


	# MOSTRA APENAS A UI DA CUTSCENE

	await get_tree().create_timer(4.0).timeout

	# Zoom OUT cinematográfico
	zoom_camera(Vector2(0.15, 0.15), 1.5)

	await get_tree().create_timer(5.0).timeout
	if gameui:
		gameui.show_cutscene_ui()
	await get_tree().create_timer(5.0).timeout

	# Esconde UI da cutscene
	if gameui:
		gameui.hide_cutscene_ui()

	# Voltar zoom normal
	zoom_camera(Vector2(0.8, 0.8), 1.5)

	start_gameplay()
	if gameui:
		gameui.show_hud() 


# --------------------------------------------------
# GAMEPLAY
# --------------------------------------------------
func start_gameplay():
	GameManager.allow_timer = true
	player.in_cutscene = false

	if horde_manager:
		print("Level pronto — iniciando hordas.")
		horde_manager.show_horde_message_and_start()
	else:
		print("ERRO: HordeManager NÃO encontrado!")


# --------------------------------------------------
# GAME OVER
# --------------------------------------------------
func trigger_game_over():
	if gameui:
		gameui.queue_free()
		gameui = null

	# Para o loop da música no game over
	is_music_looping = false
	
	var game_over: GameOver = game_over_ui.instantiate()
	game_over.monsters_defeated = 999
	game_over.time_survived = "01:58"

	add_child(game_over)


# --------------------------------------------------
# VICTORY 
# --------------------------------------------------
func trigger_victory():
	if gameui:
		gameui.queue_free()
		gameui = null

	# Para o loop da música na vitória
	is_music_looping = false
	
	var victory: VictoryScreen = victory_ui.instantiate()
	add_child(victory)
