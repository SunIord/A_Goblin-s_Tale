extends Sprite2D

@export var generation_amount: int = 10
@export var lifetime: float = 8.0   # ← Tempo até a carne sumir

@onready var Area2d: Area2D = $Area2D
@onready var sfx = $meat_sfx as AudioStreamPlayer

var can_eat: bool = false
var audio_player_template: AudioStreamPlayer2D

func _ready():
	# Timer para desaparecer caso não seja coletada
	despawn_after_delay()

	# Prepara áudio pré-carregado
	audio_player_template = AudioStreamPlayer2D.new()
	audio_player_template.stream = sfx.stream
	audio_player_template.volume_db = sfx.volume_db

	# Delay para evitar coleta imediatamente ao spawn
	await get_tree().create_timer(0.1).timeout
	can_eat = true

func despawn_after_delay():
	# Timer individual para essa carne
	await get_tree().create_timer(lifetime).timeout

	# Se ainda não foi coletada, remove
	if is_instance_valid(self):
		queue_free()

func able_to_eat() -> void:
	can_eat = true

func _on_area_2d_body_entered(body):
	if not can_eat:
		return
	
	if body.name == "player":
		can_eat = false  # Previne coletas múltiplas
		
		# CALCULA A CURA REALMENTE NECESSÁRIA
		var current_health = body.health
		var max_health = body.max_health
		var heal_possible = max_health - current_health
		
		# Toca o som de coleta (SOM RESTAURADO)
		var audio_player = audio_player_template.duplicate()
		get_parent().add_child(audio_player)
		audio_player.global_position = global_position
		audio_player.play()
		audio_player.finished.connect(audio_player.queue_free)
		# Só cura se o player precisar
		if heal_possible > 0:
			# A cura não pode exceder o necessário nem a geração da carne
			var actual_heal = min(generation_amount, heal_possible)
			
			# Aplica a cura EXATA necessária
			body.heal(actual_heal)
			
			print("Carne consumida! Cura aplicada: ", actual_heal, 
				  " | Vida antes: ", current_health, 
				  " | Vida depois: ", body.health)
		else:
			# Player já está com vida cheia - não faz nada visual/sonoro
			print("Player já está com vida cheia. Carne ignorada.")
		
		# Remove a carne (agora funciona)
		queue_free()

#func _on_animation_player_animation_finished(anim_name):
	#can_eat = true
