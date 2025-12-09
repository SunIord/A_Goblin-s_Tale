extends Node2D

@export var speed: float = 1.5
@export var attack_cooldown = 0.0

var enemy: Enemy
var animation_player: AnimatedSprite2D
var input_vector: Vector2
var is_following := true
var is_attacking: bool = false  # ← NOVO: Estado de ataque

# Distância mínima para evitar grude
const MIN_DISTANCE = 10.0

func _ready():
	enemy = get_parent()
	animation_player = enemy.get_node("AnimatedSprite2D")

func _process(delta):
	rotate_sprite()
	attack_cooldown = max(attack_cooldown - delta, 0.0)
	
	# Controle de animação
	if not is_attacking:
		play_walk_anim()

func _physics_process(delta) -> void:
	var player_pos = GameManager.player_position
	var diff = player_pos - enemy.position
	var distance = diff.length()

	if distance > MIN_DISTANCE:
		input_vector = diff.normalized()
		if is_following and not is_attacking:  # ← Não move se atacando
			move(input_vector)
	else:
		enemy.velocity = Vector2.ZERO

	enemy.move_and_slide()

	check_collisions()

func move(input_vector: Vector2) -> void:
	if GameManager.is_game_over:
		return

	var target_velocity = input_vector * speed * 100.0
	enemy.velocity = lerp(enemy.velocity, target_velocity, 0.25)

func rotate_sprite() -> void:
	if input_vector.x > 0:
		animation_player.flip_h = false
	elif input_vector.x < 0:
		animation_player.flip_h = true

func play_walk_anim() -> void:
	# Verifica se existe animação "walk"
	if animation_player.sprite_frames.has_animation("walk"):
		animation_player.play("walk")

func play_attack_anim() -> void:
	# Verifica se existe animação "attack" para este inimigo
	if animation_player.sprite_frames.has_animation("attack"):
		is_attacking = true
		animation_player.play("attack")
		
		# Espera a animação terminar (tempo aproximado)
		await get_tree().create_timer(0.5).timeout
		is_attacking = false
	else:
		# Se não tem animação de ataque, apenas pausa breve
		is_attacking = true
		await get_tree().create_timer(0.3).timeout
		is_attacking = false

func check_collisions():
	if attack_cooldown > 0 or is_attacking:
		return

	for i in range(enemy.get_slide_collision_count()):
		var collision = enemy.get_slide_collision(i)
		var collider = collision.get_collider()

		if collider and collider.is_in_group("player"):
			# Causa dano
			collider.damage(10)
			
			# Toca animação de ataque
			play_attack_anim()
			
			attack_cooldown = 1.0   # tempo entre ataques
			break
