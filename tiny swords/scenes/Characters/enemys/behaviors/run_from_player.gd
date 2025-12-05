extends Node2D

@export var speed: float = 1.5
@export var baa_interval_min: float = 3.0
@export var baa_interval_max: float = 6.0
@export var detection_range: float = 300.0

@onready var input_vector: Vector2

var enemy: Sheep
var seeing_area: Area2D 
var animation_player: AnimatedSprite2D 
var is_following: bool
var is_attacking: bool
var baa_timer: float = 0.0
var next_baa_time: float = 0.0
var baa_sfx: AudioStreamPlayer

func _ready():
	enemy = get_parent()
	animation_player = enemy.get_node("AnimatedSprite2D")
	seeing_area = enemy.get_node("Area2D")
	
	# Pega o áudio do balido usando o método getter da ovelha
	if enemy.has_method("get_baa_sfx"):
		baa_sfx = enemy.get_baa_sfx()
		print("Áudio do balido conectado!")
	else:
		print("AVISO: Ovelha não tem método get_baa_sfx()")
	
	# Define o primeiro intervalo aleatório
	next_baa_time = randf_range(baa_interval_min, baa_interval_max)

func _process(delta):
	play_run_idle_anim()
	rotate_sprite()
	update_baa(delta)
	
func _physics_process(delta) -> void:
	var player_pos = GameManager.player_position
	var difference = enemy.position - player_pos
	input_vector = difference.normalized()
	var bodies = seeing_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			is_following = true
			move(input_vector)
	enemy.move_and_slide()

func rotate_sprite()-> void:
	if input_vector.x > 0:
		animation_player.flip_h = false
	elif input_vector.x < 0:
		animation_player.flip_h = true

func play_run_idle_anim() ->void:
	if is_following && !is_attacking:
		animation_player.play("walk")
	elif !is_following:
		animation_player.play("idle")
				
func move(input_vector:Vector2)-> void:
	var target_velocity = input_vector * speed * 100.0
	enemy.velocity = lerp(enemy.velocity,target_velocity,0.02)

func stop(input_vector:Vector2)-> void:
	var target_velocity = input_vector * Vector2(0,0)
	enemy.velocity = lerp(enemy.velocity,target_velocity,0.08)

func update_baa(delta: float):
	# Atualiza o timer
	baa_timer += delta
	
	# Verifica se o player está perto o suficiente
	var player_pos = GameManager.player_position
	var distance_to_player = enemy.position.distance_to(player_pos)
	var player_in_range = distance_to_player <= detection_range
	
	# Só balir se o player estiver no alcance e o timer expirou
	if player_in_range and baa_timer >= next_baa_time:
		play_baa_sound()
		baa_timer = 0.0
		next_baa_time = randf_range(baa_interval_min, baa_interval_max)

func play_baa_sound():
	# Toca o som do balido
	if baa_sfx and not baa_sfx.playing:
		baa_sfx.play()
		print("🐑 Baa! Próximo balido em ", round(next_baa_time), " segundos")

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		is_following = false
		stop(input_vector)
