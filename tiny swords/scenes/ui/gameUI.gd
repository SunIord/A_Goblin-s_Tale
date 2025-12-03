class_name GameUI
extends CanvasLayer

@onready var timer_label: Label = %timer_label
@onready var death_label: Label = %death_label
@onready var gold_label: Label = %gold_label
@onready var fire_bar: TextureProgressBar = %FireBar
@onready var super_timer: Timer = $Super_attack_timer
@onready var horde_label: Label = $HordeLabel

var can_time := true


func _ready():
	horde_label.visible = false

	# Procura o HordeManager automaticamente
	var horde_manager = get_tree().get_first_node_in_group("horde_manager")
	if horde_manager:
		horde_manager.horde_message.connect(show_horde)
	else:
		print("HordeManager NÃO encontrado!")


func show_horde(text: String) -> void:
	horde_label.text = text
	horde_label.visible = true

	# Faz a Label sumir depois de 2.5 segundos
	await get_tree().create_timer(2.5).timeout

	# Confere se ainda está visível (caso outra horda iniciou no meio)
	if horde_label.text == text:
		horde_label.visible = false


func _process(delta: float):
	timer_label.text = GameManager.time_elapsed_string
	death_label.text = str(GameManager.death_count)
	gold_label.text = str(GameManager.gold_count)
	fire_bar.value = 15 - super_timer.time_left
	try_to_time()


func try_to_time():
	if fire_bar.value == 15:
		super_timer.stop()
	if can_time:
		super_timer_countdown()


func increase_gold():
	GameManager.gold_count += 1
	
func increase_death():
	GameManager.death_count += 1

func time_passing():
	fire_bar.value = GameManager.time_elapsed

func super_timer_countdown():
	can_time = false
	super_timer.start(15)

func value_back() -> bool:
	return fire_bar.value == 15

func restart():
	can_time = true
