class_name GameUI
extends CanvasLayer


@onready var timer_label:Label = %timer_label
@onready var death_label:Label = %death_label
@onready var fire_bar: TextureProgressBar = %FireBar
@onready var super_timer: Timer = $Super_attack_timer
@onready var can_time = true

func _process(delta: float):
	timer_label.text = GameManager.time_elapsed_string
	death_label.text = str(GameManager.death_count)
	fire_bar.set_value(15 - super_timer.get_time_left())
	try_to_time()
	
func try_to_time():
	if fire_bar.get_value() == 15:
		super_timer.stop()
		
	if can_time:
		super_timer_countdown()
	
func increase_death()->void:
	GameManager.death_count += 1

func time_passing()->void:
	fire_bar.value = GameManager.time_elapsed

func super_timer_countdown():
	can_time = false
	super_timer.start(15)		

func value_back()->bool:
	if fire_bar.get_value() == 15:
		return true
	else:
		return false

func restart()->void:
	can_time = true
