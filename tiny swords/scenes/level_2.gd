extends Node2D

@onready var gameui = $GameUI
@export var game_over_ui: PackedScene
@export var victory_ui: PackedScene 
@onready var sfx = $music as AudioStreamPlayer
@onready var horde_manager = $HordeManager
@onready var camera = $YSort/player/Camera2D
@onready var player = $YSort/player
@onready var intro_end = $CutsceneEndPoint
@onready var intro_end2 = $CutsceneEndPoint2

func _ready():
	GameManager.complete_level()
	GameManager.game_over.connect(trigger_game_over)
	GameManager.reset_horde()

	MusicPlayer.stop()
	sfx.play()

	if not GameManager.level2_cutscene_played:
		start_intro_cutscene()
	else:
		start_gameplay()


# --------------------------------------------------
# CAMERA
# --------------------------------------------------
func zoom_camera(target_zoom: Vector2, duration: float):
	var tween = create_tween()
	tween.tween_property(camera, "zoom", target_zoom, duration)


# --------------------------------------------------
# CUTSCENE
# --------------------------------------------------
func start_intro_cutscene():
	GameManager.level2_cutscene_played = true

	# Travar sistemas
	GameManager.allow_timer = false

	if horde_manager:
		horde_manager.active = false
		
	if gameui:
		gameui.hide_all()
	
	var targets : Array[Vector2] = [
	intro_end.global_position,
	intro_end2.global_position
	]
	# ▶️ INICIA CUTSCENE COM DOIS ENDPOINTS
	player.start_cutscene(targets)

	# Espera o player chegar aos dois pontos
	player.cutscene_path_finished.connect(_on_cutscene_path_finished, CONNECT_ONE_SHOT)

	# Tempo inicial da cena
	await get_tree().create_timer(7.0).timeout

	# Zoom OUT cinematográfico
	zoom_camera(Vector2(0.15, 0.15), 1.5)
	await get_tree().create_timer(2.0).timeout

	if gameui:
		gameui.show_cutscene_ui()

	await get_tree().create_timer(4.0).timeout
	if gameui:
		gameui.hide_cutscene_ui()

	# Voltar zoom normal
	zoom_camera(Vector2(0.8, 0.8), 1.5)


func _on_cutscene_path_finished():
	# Player terminou o trajeto da cutscene
	await get_tree().create_timer(3.0).timeout
	start_gameplay()

	if gameui:
		gameui.show_hud()


# --------------------------------------------------
# GAMEPLAY
# --------------------------------------------------
func start_gameplay():
	GameManager.allow_timer = true

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

	var victory: VictoryScreen = victory_ui.instantiate()
	add_child(victory)
