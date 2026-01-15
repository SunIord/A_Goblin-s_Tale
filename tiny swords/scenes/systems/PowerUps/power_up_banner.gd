extends CanvasLayer
class_name PowerUpBanner

@export var power_up_card_scene: PackedScene
@export var available_powerups: Array[PowerUpData]

@onready var container: HBoxContainer = \
	$Panel/VBoxContainer/MarginContainer/HBoxContainer
@onready var vbox_container: VBoxContainer = $Panel/VBoxContainer  # Adicione esta linha

var message_label: Label = null

func show_powerups():
	clear_cards()
	_remove_message_label()  # Remove mensagem anterior se existir

	var chosen = pick_random_powerups(3)
	
	if chosen.is_empty():
		# SEM ITENS DISPONÍVEIS - Cria Label dinamicamente
		_create_message_label()
	else:
		for power_data in chosen:
			var card = power_up_card_scene.instantiate() as PowerUpCard
			container.add_child(card)
			card.setup(power_data)

func clear_cards():
	for child in container.get_children():
		child.queue_free()
	_remove_message_label()

func _create_message_label():
	# Cria Label dinamicamente
	message_label = Label.new()
	message_label.text = "SEM ITENS NA LOJA"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Estiliza (opcional)
	message_label.add_theme_font_size_override("font_size", 24)
	
	# Adiciona ao VBoxContainer (acima do container de cards)
	vbox_container.add_child(message_label)
	vbox_container.move_child(message_label, 1)  # Coloca na posição 1 (após o título)

func _remove_message_label():
	if message_label and is_instance_valid(message_label):
		message_label.queue_free()
		message_label = null

func pick_random_powerups(amount: int) -> Array[PowerUpData]:
	# Filtra apenas os NÃO comprados
	var available: Array[PowerUpData] = []
	for powerup in available_powerups:
		if not GameManager.is_powerup_purchased(powerup.id):
			available.append(powerup)
	
	
	# Se não tem enough, retorna menos (pode ficar slot vazio)
	var copy = available.duplicate()
	copy.shuffle()
	return copy.slice(0, min(amount, copy.size()))

func _on_leave_button_pressed() -> void:
	pass # Replace with function body.
