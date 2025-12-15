extends Node

@export var hordes : Array[HordeConfig]
@export var mob_spawner : MobSpawner
@onready var powerup_banner: PowerUpBanner = get_parent().get_node("PowerUpBanner")


var current_horde_index := 0
var kill_counter := 0
var time_remaining := 0.0
var active := false

signal horde_message(text)
signal timer_manage(show_timer: bool) 
signal time_update(time_string: String) 

func _ready() -> void:
	var leave_button = powerup_banner.get_node("Panel/VBoxContainer/MarginContainer2/HBoxContainer/LeaveButton")
	leave_button.pressed.connect(Callable(self, "_on_powerup_leave_pressed"))

# Mensagem antes da horda
func show_horde_message_and_start():
	var msg := ""
	var h := GameManager.horde
	var cfg := hordes[h - 1]

	match cfg.horde_type:
		HordeConfig.HordeType.TUTORIAL:
			msg = "Tutorial — Aprenda os controles!"
		HordeConfig.HordeType.KILL_COUNT:
			msg = "Horda %d — Derrote %d inimigos!" % [h, cfg.enemy_amount]
		HordeConfig.HordeType.SURVIVE_TIME:
			msg = "Horda %d — Sobreviva por %ds!" % [h, cfg.survive_time]

	horde_message.emit(msg)

	await get_tree().create_timer(6).timeout
	start_horde()

# Início da horda
func start_horde():
	var h := GameManager.horde
	var cfg := hordes[h - 1]

	mob_spawner.set_creatures(cfg.creature_scenes)
	
	active = true
	mob_spawner.start_spawning(cfg.spawn_rate)
	
	var is_survival_horde = cfg.horde_type == HordeConfig.HordeType.SURVIVE_TIME
	
	if is_survival_horde:
		time_remaining = cfg.survive_time
		timer_manage.emit(true)
	else:
		timer_manage.emit(false)

	print("Horda iniciada: idx=", current_horde_index,"tipo =", cfg.horde_type)

# Contagem de mortes
func on_enemy_killed():
	if not active:
		return

	var h := GameManager.horde
	var cfg := hordes[h - 1]

	if cfg.horde_type in [HordeConfig.HordeType.TUTORIAL, HordeConfig.HordeType.KILL_COUNT]:
		if GameManager.death_count >= cfg.enemy_amount:
			_end_horde()

# Contagem de tempo 
func _process(delta):
	if not active:
		return

	var h := GameManager.horde
	var cfg := hordes[h - 1]

	if cfg.horde_type == HordeConfig.HordeType.SURVIVE_TIME:
		time_remaining -= delta
		
		if time_remaining < 0.0:
			time_remaining = 0.0
			
		var time_remaining_second: int = floori(time_remaining)
		var min: int = time_remaining_second / 60
		var sec: int = time_remaining_second % 60
		var time_string = "%02d:%02d" % [min, sec]
		
		time_update.emit(time_string)

		if time_remaining <= 0:
			_end_horde()

# Fim da horda
func _end_horde():
	if not active: 
		return
		
	print("Horda finalizada:", current_horde_index)
	timer_manage.emit(false)
	
	active = false
	mob_spawner.stop_spawning()
	mob_spawner._kill_all_enemies()
	GameManager.death_count = 0

	if GameManager.horde < hordes.size():
		GameManager.increase_horde()
		print("Horde:", GameManager.horde)
		show_powerups_between_hordes()
	else:
		GameManager.complete_level()
		
func show_powerups_between_hordes():
	active = false  # pausa as hordas
	powerup_banner.visible = true
	powerup_banner.show_powerups()
func _on_powerup_leave_pressed():
	# Fecha o banner
	powerup_banner.visible = false
	powerup_banner.clear_cards()
	
	# Inicia a próxima horda
	show_horde_message_and_start()
