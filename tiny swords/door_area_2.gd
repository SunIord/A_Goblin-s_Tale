extends Node2D

@export var new_scene_path: String = "res://scenes/level_2.tscn"
@export var required_arena: String = "level_1"  # Arena que precisa completar

var player_in_range = false
@onready var button = $button
@onready var proximity_area = $ProximityArea
@onready var button_sfx = $button2 as AudioStreamPlayer

func _ready():
	# Verifica se a arena requerida foi completada
	var can_access = GameManager.is_arena_completed(required_arena)
	print("Porta para", new_scene_path, " - Acesso:", "LIBERADO" if can_access else "BLOQUEADO")

# Função chamada quando o jogador entra na área
func _on_proximity_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		
		# Só mostra botão se tiver acesso
		if GameManager.is_arena_completed(required_arena):
			button.visible = true
			print("Pressione E para entrar em", new_scene_path)
		else:
			print("Complete", required_arena, "primeiro!")

# Função chamada quando o jogador sai da área
func _on_proximity_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		button.visible = false

# Função chamada quando o botão é pressionado
func _on_button_pressed():
	if player_in_range:
		if GameManager.is_arena_completed(required_arena):
			button_sfx.play()
			print("Entrando em", new_scene_path)
			_change_scene()
		else:
			print("Acesso negado! Complete", required_arena, "primeiro.")

# Função para mudar de cena
func _change_scene():
	get_tree().change_scene_to_file(new_scene_path)
