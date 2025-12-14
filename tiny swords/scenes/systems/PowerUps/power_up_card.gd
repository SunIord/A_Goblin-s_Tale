extends Control
class_name PowerUpCard

@onready var icon: TextureRect = $VBoxContainer/Panel/TextureRect
@onready var name_label: Label = $VBoxContainer/PowerName
@onready var description_label: Label = $VBoxContainer/MarginContainer2/PowerDescription
@onready var price_label: Label = $VBoxContainer/MarginContainer3/HBoxContainer/PowerPrice
@onready var buy_button: Button = $VBoxContainer/MarginContainer3/HBoxContainer/BuyButton

var data: PowerUpData

func setup(power_data: PowerUpData) -> void:
	data = power_data

	name_label.text = power_data.title
	description_label.text = power_data.description
	price_label.text = str(power_data.price)

	if power_data.icon:
		icon.texture = power_data.icon

	buy_button.pressed.connect(_on_buy_pressed)

func _on_buy_pressed():
	print("Comprou:", data.id)
	# Aqui depois você:
	# - desconta gold
	# - aplica efeito
	# - fecha banner
