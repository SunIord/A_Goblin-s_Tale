extends Sprite2D

@export var generation_amount: int = 10

@onready var Area2d: Area2D = $Area2D
@onready var sfx = $collect as AudioStreamPlayer

var can_collect: bool = false
var audio_player_template: AudioStreamPlayer2D

func _ready():
	# Cria o template do áudio PRÉ-CONFIGURADO (sem delay na coleta)
	audio_player_template = AudioStreamPlayer2D.new()
	audio_player_template.stream = sfx.stream
	audio_player_template.volume_db = sfx.volume_db
	
	# Pequeno delay antes de permitir coleta
	await get_tree().create_timer(0.1).timeout
	can_collect = true

func _on_area_2d_body_entered(body):
	if not can_collect:
		return
	
	if body.name == "player":
		can_collect = false  # Previne coletas múltiplas
		
		# Usa o template PRÉ-CONFIGURADO (rápido)
		var audio_player = audio_player_template.duplicate()
		get_parent().add_child(audio_player)
		audio_player.global_position = global_position
		audio_player.play()
		audio_player.finished.connect(audio_player.queue_free)
		
		# Coleta o ouro
		body.collect(generation_amount)
		
		# Remove a moeda
		queue_free()

func _on_animation_player_animation_finished(anim_name):
	can_collect = true
