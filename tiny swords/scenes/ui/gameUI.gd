class_name GameUI
extends CanvasLayer

@onready var timer_panel: Control = $Timer_Panel
@onready var timer_label: Label = %timer_label
@onready var death_label: Label = %death_label
@onready var gold_label: Label = %gold_label
@onready var fire_bar: TextureProgressBar = %FireBar
@onready var super_timer: Timer = $Super_attack_timer
@onready var horde_panel: Control = $Horde_goal_panel
@onready var horde_label: Label = $Horde_goal_panel/HordeLabel

var super_attack_ready := true

func _ready():
	var player_node = get_tree().get_first_node_in_group("player")
	var horde_manager = get_tree().get_first_node_in_group("horde_manager")
	horde_panel.visible = false
	
	if player_node:
		# Conecta o sinal de uso do Player para INICIAR o cooldown
		player_node.super_attack_used.connect(start_super_attack_cooldown)
	

	if horde_manager:
		horde_manager.horde_message.connect(show_horde)
		horde_manager.timer_manage.connect(_on_timer_manage)
		horde_manager.time_update.connect(_on_time_update)
	
	# Inicializa o ataque como PRONTO e barra cheia
	reset_super_attack()


func show_horde(text: String) -> void:
	horde_label.text = text
	horde_panel.visible = true
	await get_tree().create_timer(2.5).timeout
	if horde_label.text == text:
		horde_panel.visible = false

func _on_timer_manage(show_timer: bool) -> void:
	print(show_timer)
	timer_panel.visible = show_timer

func _on_time_update(time_string: String) -> void:
	timer_label.text = time_string

# ------------------------------------------------------------------
# FUNÇÃO _PROCESS (ATUALIZAÇÃO VISUAL)
# ------------------------------------------------------------------
func _process(delta: float):
	death_label.text = str(GameManager.death_count)
	gold_label.text = str(GameManager.gold_count)
	
	# Se o ataque estiver pronto, a barra FICA em 15.
	if super_attack_ready:
		fire_bar.value = 15
	else:
		fire_bar.value = 15 - super_timer.time_left


func increase_gold():
	GameManager.gold_count += 1

func increase_death():
	GameManager.death_count += 1
	var horde_manager = get_tree().get_first_node_in_group("horde_manager")
	if horde_manager:
		horde_manager.on_enemy_killed()

# ------------------------------------------------------------------
# FUNÇÕES DE CONTROLE DE ESTADO
# ------------------------------------------------------------------

# Chamado pelo sinal 'super_attack_used' do Player.
func start_super_attack_cooldown():
	# Inicia o cooldown SOMENTE se estiver pronto.
	if super_attack_ready: 
		super_attack_ready = false
		super_timer.start(0)

func is_super_ready() -> bool:
	return super_attack_ready

# Usado para inicialização e redefinição ao estado "PRONTO".
func reset_super_attack():
	super_attack_ready = true
	fire_bar.value = 15 # Valor máximo para a barra cheia
	super_timer.stop() # Garante que o timer esteja parado.


func _on_super_attack_timer_timeout() -> void:
		super_attack_ready = true
