extends Node2D

@export var new_scene_path: String  # Caminho da nova cena (fase) para onde o jogador será levado
var player_in_range = false  # Para verificar se o jogador está dentro da área de proximidade
@onready var button = $button  # Referência ao botão
@onready var proximity_area = $ProximityArea  # Referência à área de proximidade


# Função chamada quando o jogador entra na área
func _on_proximity_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Verifica se o que entrou é o jogador
		player_in_range = true
		button.visible = true  # Exibe o botão

# Função chamada quando o jogador sai da área
func _on_proximity_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):  # Verifica se o que saiu é o jogador
		player_in_range = false
		button.visible = false  # Esconde o botão

# Função chamada quando o botão é pressionado
func _on_button_pressed():
	if player_in_range:  # Verifica se o jogador está dentro da área antes de mudar de cena
		_change_scene()  # Chama a função para mudar de cena

# Função para mudar de cena
func _change_scene():
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")  # Muda para a nova cena especificada
