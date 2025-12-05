class_name Sheep
extends Node2D

@export var health: int = 10
@export var meat_prefab: PackedScene

@onready var baaSfx = $baa_sfx as AudioStreamPlayer
@onready var hitSfx = $hit_sfx as AudioStreamPlayer
@onready var dyingSfx = $dying_sfx as AudioStreamPlayer

# Templates de áudio para evitar delay
var dying_audio_template: AudioStreamPlayer2D
var meat_audio_template: AudioStreamPlayer2D

func _ready():
	# Pré-configura os áudios que precisam de posição
	if dyingSfx and dyingSfx.stream:
		dying_audio_template = AudioStreamPlayer2D.new()
		dying_audio_template.stream = dyingSfx.stream
		dying_audio_template.volume_db = dyingSfx.volume_db

func damage(amount:int) -> void:
	health -= amount
	
	# Toca som de hit (AudioStreamPlayer normal)
	if hitSfx:
		hitSfx.play()
	
	# Efeito visual
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	print("Inimigo recebeu dano de ", amount, ". A vida total é de ", health)
	
	if health <= 0:
		die()

func die() -> void:
	# Toca som de morte (com posição, AudioStreamPlayer2D)
	if dying_audio_template:
		var dying_audio = dying_audio_template.duplicate()
		get_parent().add_child(dying_audio)
		dying_audio.global_position = global_position
		dying_audio.play()
		dying_audio.finished.connect(dying_audio.queue_free)
	elif dyingSfx:  # Fallback
		dyingSfx.play()
	
	# Spawna a carne
	if meat_prefab:
		var meat_object = meat_prefab.instantiate()
		meat_object.position = Vector2(position.x, position.y + 10)
		get_parent().add_child(meat_object)
		
		# Conecta o som de coletar carne à carne spawnada
		if meat_audio_template:
			# Precisamos esperar a carne ser adicionada à cena
			await get_tree().process_frame
			setup_meat_sound(meat_object)
	
	queue_free()

func setup_meat_sound(meat_object: Node2D):
	# Adiciona um script ou conecta o som à carne
	if meat_object.has_method("set_collect_sound"):
		meat_object.set_collect_sound(meat_audio_template)
	else:
		# Alternativa: adiciona componente de áudio à carne
		var meat_audio = meat_audio_template.duplicate()
		meat_object.add_child(meat_audio)
		meat_audio.name = "collect_sfx"
		
func get_baa_sfx() -> AudioStreamPlayer:
	return $baa_sfx
