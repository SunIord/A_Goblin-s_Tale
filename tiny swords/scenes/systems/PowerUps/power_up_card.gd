extends Control
class_name PowerUpCard

@onready var icon: TextureRect = $MarginContainer/VBoxContainer/Panel/TextureRect
@onready var name_label: Label = $MarginContainer/VBoxContainer/PowerName
@onready var description_label: Label = $MarginContainer/VBoxContainer/PowerDescription
@onready var price_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/PowerPrice
@onready var buy_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/BuyButton

@export var firefly_scene: PackedScene
var data: PowerUpData

func setup(power_data: PowerUpData) -> void:
	data = power_data

	name_label.text = power_data.title
	description_label.text = power_data.description
	price_label.text = str(power_data.price)

	if power_data.icon:
		icon.texture = power_data.icon

	# Verifica se já foi comprado
	if GameManager.is_powerup_purchased(data.id):
		buy_button.text = "COMPRADO"
		buy_button.disabled = true
	else:
		buy_button.pressed.connect(_on_buy_pressed)

func _on_buy_pressed():
	if GameManager.gold_count < data.price:
		print("Ouro insuficiente!")
		return
	
	# Compra o power-up
	GameManager.gold_count -= data.price
	GameManager.purchase_powerup(data.id)
	
	# Aplica o efeito específico
	_apply_powerup_effect()
	
	print("Comprou:", data.id)
	
	# Atualiza UI
	buy_button.text = "COMPRADO"
	buy_button.disabled = true

func _apply_powerup_effect():
	var powerup_id = str(data.id)  # Converte para string para segurança
	
	print("Aplicando power-up ID:", powerup_id)
	
	match powerup_id:
		"health_upgrade", "1":
			# Calcula a porcentagem atual de vida ANTES do upgrade
			var health_percentage_before = float(GameManager.current_health) / float(GameManager.max_health)
			print("Porcentagem de vida antes:", health_percentage_before * 100, "%")
			
			# Aumenta a vida máxima
			var extra_health = GameManager.max_health * 0.10  # 10%
			GameManager.max_health += int(extra_health)
			
			# Aumenta a vida atual PROPORCIONALMENTE
			GameManager.current_health = int(GameManager.max_health * health_percentage_before)
			
			print("Vida aumentada para:", GameManager.max_health)
			print("Vida atual ajustada para:", GameManager.current_health)
			
		
		
		"damage_upgrade", "2":
			GameManager.base_damage += 2
			print("Dano aumentado para:", GameManager.base_damage)
			

		
		"speed_upgrade", "3":
			GameManager.move_speed *= 1.25  # +25%
			print("Velocidade aumentada para:", GameManager.move_speed)
		
		"atk_speed_upgrade", "4":
			GameManager.attack_speed_multiplier *= 0.75  # -25% tempo = +33% velocidade
			
			var players = get_tree().get_nodes_in_group("player")
			if not players.is_empty():
				var player = players[0]
				if player.get("base_attack_cooldown") != null:
					player.attack_cooldown = player.base_attack_cooldown * GameManager.attack_speed_multiplier
				else:
					player.attack_cooldown *= 0.75
			
			print("Velocidade de ataque aumentada! Multiplicador: ", GameManager.attack_speed_multiplier)
		
		"firefly_upgrade", "5":
			# APENAS salva no GameManager
			GameManager.has_firefly = true
			print("Firefly adquirido (salvo no GameManager)")
			
			# OPÇÃO: Notifica o player atual para spawnar
			var players = get_tree().get_nodes_in_group("player")
			if not players.is_empty():
				var player = players[0]
				if player.has_method("_spawn_firefly_if_needed"):
					player._spawn_firefly_if_needed()
		
		_:
			print("Power-up desconhecido:", powerup_id)
