extends Node

@export var hordes : Array[HordeConfig]
@export var mob_spawner : MobSpawner

var current_horde_index := 0
var kill_counter := 0
var time_remaining := 0.0
var active := false

signal horde_message(text)

func _ready():
	print("HordeManager inicializado")
	print("Iniciando hordas")
	start_hordes()

func start_hordes():
	current_horde_index = 0
	_show_horde_message_and_start()

# -------------------------------------------------------------------
# NOVO → Exibe mensagem antes de cada horda
# -------------------------------------------------------------------
func _show_horde_message_and_start():
	var cfg = hordes[current_horde_index]

	var msg := ""
	match cfg.horde_type:
		HordeConfig.HordeType.TUTORIAL:
			msg = "Tutorial — Aprenda os controles!"
		HordeConfig.HordeType.KILL_COUNT:
			msg = "Horda %d — Derrote %d inimigos!" % [current_horde_index + 1, cfg.enemy_amount]
		HordeConfig.HordeType.SURVIVE_TIME:
			msg = "Horda %d — Sobreviva por %ds!" % [current_horde_index + 1, cfg.survive_time]

	# Emite para o HUD
	horde_message.emit(msg)

	# Espera 2.5s para mostrar a mensagem
	await get_tree().create_timer(8).timeout

	# Agora sim inicia a horda de verdade
	_start_horde()
# -------------------------------------------------------------------


func _start_horde():
	var cfg = hordes[current_horde_index]
	kill_counter = 0

	match cfg.horde_type:

		HordeConfig.HordeType.TUTORIAL:
			active = true
			mob_spawner.spawn_tutorial_enemies()
		
		HordeConfig.HordeType.KILL_COUNT:
			active = true
			mob_spawner.start_spawning(cfg.spawn_rate)
		
		HordeConfig.HordeType.SURVIVE_TIME:
			active = true
			time_remaining = cfg.survive_time
			mob_spawner.start_spawning(cfg.spawn_rate)

	print("Horda iniciada:", current_horde_index, cfg.horde_type)


func on_enemy_killed():
	if not active:
		return

	var cfg = hordes[current_horde_index]

	if cfg.horde_type == HordeConfig.HordeType.KILL_COUNT:
		kill_counter += 1
		if kill_counter >= cfg.enemy_amount:
			_end_horde()


func _process(delta):
	if not active:
		return

	var cfg = hordes[current_horde_index]

	if cfg.horde_type == HordeConfig.HordeType.SURVIVE_TIME:
		time_remaining -= delta
		if time_remaining <= 0:
			_end_horde()


func _end_horde():
	print("Horda finalizada:", current_horde_index)
	active = false
	mob_spawner.stop_spawning()

	current_horde_index += 1

	if current_horde_index < hordes.size():
		_show_horde_message_and_start()
	else:
		print("Todas as hordas concluídas!")
