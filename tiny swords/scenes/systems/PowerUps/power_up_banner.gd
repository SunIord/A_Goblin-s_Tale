extends CanvasLayer
class_name PowerUpBanner

@export var power_up_card_scene: PackedScene
@export var available_powerups: Array[PowerUpData]

@onready var container: HBoxContainer = \
	$Panel/VBoxContainer/MarginContainer/HBoxContainer

func show_powerups():
	clear_cards()

	var chosen = pick_random_powerups(3)

	for power_data in chosen:
		var card = power_up_card_scene.instantiate() as PowerUpCard
		container.add_child(card)
		card.setup(power_data)

func clear_cards():
	for child in container.get_children():
		child.queue_free()

func pick_random_powerups(amount: int) -> Array[PowerUpData]:
	# 1. Filtra apenas os NÃO comprados
	var available: Array[PowerUpData] = []
	for powerup in available_powerups:
		if not GameManager.is_powerup_purchased(powerup.id):
			available.append(powerup)
	
	print("Power-ups disponíveis: ", available.size(), "/", available_powerups.size())
	
	# 2. Se não tem enough, retorna menos (pode ficar slot vazio)
	var copy = available.duplicate()
	copy.shuffle()
	return copy.slice(0, min(amount, copy.size()))


func _on_leave_button_pressed() -> void:
	pass # Replace with function body.aaaa
