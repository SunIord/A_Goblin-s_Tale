class_name GameUI
extends CanvasLayer

@onready var timer_label: Label = %timer_label
@onready var death_label: Label = %death_label
@onready var gold_label: Label = %gold_label
@onready var fire_bar: TextureProgressBar = %FireBar
@onready var super_timer: Timer = $Super_attack_timer
@onready var horde_panel: Control = $Horde_goal_panel
@onready var horde_label: Label = $Horde_goal_panel/HordeLabel

var super_attack_ready := true   # deixa explícito o estado do super ataque

func _ready():
	horde_panel.visible = false
	var horde_manager = get_tree().get_first_node_in_group("horde_manager")
	if horde_manager:
		horde_manager.horde_message.connect(show_horde)

func show_horde(text: String) -> void:
	horde_label.text = text
	horde_panel.visible = true
	await get_tree().create_timer(2.5).timeout
	if horde_label.text == text:
		horde_panel.visible = false

func _process(delta: float):
	timer_label.text = GameManager.time_elapsed_string
	death_label.text = str(GameManager.death_count)
	gold_label.text = str(GameManager.gold_count)
	fire_bar.value = 15 - super_timer.time_left

	if super_attack_ready:
		start_super_attack_cooldown()

func increase_gold():
	GameManager.gold_count += 1

func increase_death():
	GameManager.death_count += 1
	var horde_manager = get_tree().root.get_node("level_1/HordeManager")
	if horde_manager:
		horde_manager.on_enemy_killed()

func start_super_attack_cooldown():
	super_attack_ready = false
	super_timer.start(15)

func reset_super_attack():
	super_attack_ready = true
	fire_bar.value = 0
	super_timer.stop()
