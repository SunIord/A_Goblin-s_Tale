extends Node

@export var hordes : Array[HordeConfig]
@export var mob_spawner : MobSpawner

var current_horde_index := 0
var kill_counter := 0
var time_remaining := 0.0
var active := false

signal horde_message(text)
# Sinal para gerenciar a UI (mostrar/esconder o painel do timer)
signal timer_manage(show_timer: bool) 
# Sinal para atualizar o label do timer a cada frame (string formatada)
signal time_update(time_string: String) 


func _ready():
	print("HordeManager inicializado")

func start_hordes():
	print("⚡ HordeManager.start_hordes() chamado!")

	current_horde_index = 0
	_show_horde_message_and_start()

# ----------------------------------------------------------
# Mensagem antes da horda
# ----------------------------------------------------------
func _show_horde_message_and_start():
	var cfg = hordes[current_horde_index]

	var msg := ""
	match cfg.horde_type:
		HordeConfig.HordeType.TUTORIAL:
			msg = "Tutorial — Aprenda os controles!"
		HordeConfig.HordeType.KILL_COUNT:
			msg = "Horda %d — Derrote %d inimigos!" % [current_horde_index, cfg.enemy_amount]
		HordeConfig.HordeType.SURVIVE_TIME:
			msg = "Horda %d — Sobreviva por %ds!" % [current_horde_index, cfg.survive_time]

	horde_message.emit(msg)

	await get_tree().create_timer(8).timeout
	_start_horde()


# ----------------------------------------------------------
# Início da horda
# ----------------------------------------------------------
func _start_horde():
	var cfg = hordes[current_horde_index]
	mob_spawner.set_creatures(cfg.creature_scenes)
	
	active = true
	mob_spawner.start_spawning(cfg.spawn_rate)
	
	var is_survival_horde = cfg.horde_type == HordeConfig.HordeType.SURVIVE_TIME
	
	if is_survival_horde:
		time_remaining = cfg.survive_time
		timer_manage.emit(true) # Mostra o timer
	else:
		timer_manage.emit(false) # Garante que o timer esteja escondido


	print("Horda iniciada: idx=", current_horde_index,"tipo =", cfg.horde_type)


# ----------------------------------------------------------
# Contagem de mortes
# ----------------------------------------------------------
func on_enemy_killed():
	if not active:
		return

	var cfg = hordes[current_horde_index]

	# Tutorial + KillCount usam contador
	if cfg.horde_type in [HordeConfig.HordeType.TUTORIAL, HordeConfig.HordeType.KILL_COUNT]:
		if GameManager.death_count >= cfg.enemy_amount:
			_end_horde()


# ----------------------------------------------------------
# Contagem de tempo (Lógica de Decremento, Formatação e Checagem)
# ----------------------------------------------------------
func _process(delta):
	if not active:
		return

	var cfg = hordes[current_horde_index]

	if cfg.horde_type == HordeConfig.HordeType.SURVIVE_TIME:
		time_remaining -= delta
		
		if time_remaining < 0.0:
			time_remaining = 0.0
			
		var time_remaining_second: int = floori(time_remaining)
		var min: int = time_remaining_second / 60
		var sec: int = time_remaining_second % 60
		var time_string = "%02d:%02d" % [min, sec]
		
		# Emite o tempo formatado para a GameUI
		time_update.emit(time_string) 

		# Checagem de fim de tempo
		if time_remaining <= 0:
			_end_horde()


# ----------------------------------------------------------
# Fim da horda
# ----------------------------------------------------------
func _end_horde():
	# Retorna se já estiver inativo para evitar multi-chamadas
	if not active: 
		return
		
	print("Horda finalizada:", current_horde_index)
	timer_manage.emit(false) # Esconde o timer
	
	active = false
	mob_spawner.stop_spawning()
	mob_spawner._kill_all_enemies()
	GameManager.death_count = 0

	current_horde_index += 1

	if current_horde_index < hordes.size():
		_show_horde_message_and_start()
	else:
		print("Todas as hordas concluídas!")
