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
	var copy = available_powerups.duplicate()
	copy.shuffle()
	return copy.slice(0, amount)


func _on_leave_button_pressed() -> void:
	pass # Replace with function body.
