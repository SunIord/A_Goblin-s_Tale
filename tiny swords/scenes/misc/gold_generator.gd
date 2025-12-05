extends Sprite2D

@export var generation_amount: int = 10
@export var lifetime: float = 8.0   # ← Tempo até a moeda sumir

@onready var Area2d: Area2D = $Area2D
@onready var sfx = $collect as AudioStreamPlayer

var can_collect: bool = false
var audio_player_template: AudioStreamPlayer2D

func _ready():
	# Timer para desaparecer caso não seja coletado
	despawn_after_delay()

	# Prepara áudio pré-carregado
	audio_player_template = AudioStreamPlayer2D.new()
	audio_player_template.stream = sfx.stream
	audio_player_template.volume_db = sfx.volume_db

	# Delay para evitar coleta imediatamente ao spawn
	await get_tree().create_timer(0.1).timeout
	can_collect = true

func despawn_after_delay():
	# Timer individual para essa moeda
	await get_tree().create_timer(lifetime).timeout

	# Se ainda não foi coletada, remove
	if is_instance_valid(self):
		queue_free()

func _on_area_2d_body_entered(body):
	if not can_collect:
		return
	
	if body.name == "player":
		can_collect = false
		
		# Prepara o áudio rápido via template
		var audio_player = audio_player_template.duplicate()
		get_parent().add_child(audio_player)
		audio_player.global_position = global_position
		audio_player.play()
		audio_player.finished.connect(audio_player.queue_free)
		
		body.collect(generation_amount)
		queue_free()

func _on_animation_player_animation_finished(anim_name):
	can_collect = true
