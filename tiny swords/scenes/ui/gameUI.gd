class_name GameUI
extends CanvasLayer

# ----------------------------
# NÓS DO HUD (GAMEPLAY)
# ----------------------------
@onready var hud: Control = $HUD
@onready var timer_panel: Control = $HUD/Timer_Panel
@onready var timer_label: Label = %timer_label
@onready var death_label: Label = %death_label
@onready var gold_label: Label = %gold_label
@onready var fire_bar: TextureProgressBar = %FireBar
@onready var super_timer: Timer = $HUD/Super_attack_timer
@onready var horde_panel: Control = $HUD/Horde_goal_panel
@onready var horde_label: Label = $HUD/Horde_goal_panel/HordeLabel

# ----------------------------
# UI DE CUTSCENE
# ----------------------------
@onready var container_title_level: Control = $ContainerTitleLevel

var super_attack_ready := true

# ------------------------------------------------------------------
func _ready():
	# Estados iniciais
	hud.visible = true
	container_title_level.visible = false
	horde_panel.visible = false

	var player_node = get_tree().get_first_node_in_group("player")
	var horde_manager = get_tree().get_first_node_in_group("horde_manager")

	if player_node:
		player_node.super_attack_used.connect(start_super_attack_cooldown)

	if horde_manager:
		horde_manager.horde_message.connect(show_horde)
		horde_manager.timer_manage.connect(_on_timer_manage)
		horde_manager.time_update.connect(_on_time_update)

	reset_super_attack()


# ------------------------------------------------------------------
# CUTSCENE CONTROL
# ------------------------------------------------------------------
func hide_all():
	hud.visible = false
	container_title_level.visible = false
	
func show_cutscene_ui():
	hud.visible = false
	container_title_level.visible = true

func hide_cutscene_ui():
	container_title_level.visible = false
	hud.visible = true

func show_hud():
	hud.visible = true

# ------------------------------------------------------------------
# HORDE / TIMER
# ------------------------------------------------------------------
func show_horde(text: String) -> void:
	horde_label.text = text
	horde_panel.visible = true
	await get_tree().create_timer(2.5).timeout
	if horde_label.text == text:
		horde_panel.visible = false

func _on_timer_manage(show_timer: bool) -> void:
	timer_panel.visible = show_timer

func _on_time_update(time_string: String) -> void:
	timer_label.text = time_string

# ------------------------------------------------------------------
# UPDATE VISUAL
# ------------------------------------------------------------------
func _process(delta: float):
	death_label.text = str(GameManager.death_count)
	gold_label.text = str(GameManager.gold_count)

	if super_attack_ready:
		fire_bar.value = 15
	else:
		fire_bar.value = 15 - super_timer.time_left

# ------------------------------------------------------------------
# SUPER ATTACK
# ------------------------------------------------------------------
func start_super_attack_cooldown():
	if super_attack_ready:
		super_attack_ready = false
		super_timer.start()

func is_super_ready() -> bool:
	return super_attack_ready

func reset_super_attack():
	super_attack_ready = true
	fire_bar.value = 15
	super_timer.stop()

func _on_super_attack_timer_timeout() -> void:
	super_attack_ready = true
	
func increase_gold():
	GameManager.gold_count += 1

func increase_death():
	GameManager.death_count += 1
	var horde_manager = get_tree().get_first_node_in_group("horde_manager")
	if horde_manager:
		horde_manager.on_enemy_killed()
