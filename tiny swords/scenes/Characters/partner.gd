extends CharacterBody2D

@export var speed: float = 3
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
var input_vector: Vector2 = Vector2(0,0)

@export var speed_dynamite: float = 5.0
var attack_cooldown:float = 0.8
var is_running: bool = false
var was_running: bool = false
var is_attacking:bool = false

@export var dynamite_prefab:PackedScene

func _physics_process(delta) -> void:
	#obter o input vector e aplicar a velocidade
	var target_velocity = input_vector * speed * 100
	if is_attacking:
		target_velocity *= 0.5
	velocity = lerp(velocity,target_velocity,0.08)
	move_and_slide()

func _process(delta: float) -> void:
	#ler input
	GameManager.player_position = position
	read_input()
	
	#Ataque
	if Input.is_action_just_pressed("attack_side"):
		attack()
	
	update_attack_coold(delta)
	#processar animação e rodar sprite
	if !is_attacking:
		rotate_sprite()
	play_run_idle_anim()
	
func read_input() -> void:
	input_vector = Input.get_vector("move_left","move_right","move_up","move_down",0.15)
	
	#atualizar o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()
	
func rotate_sprite()->void:
	#girar o sprite
	if input_vector.x > 0:
		animation_player.flip_h = false
	elif input_vector.x < 0:
		animation_player.flip_h = true
	
func play_run_idle_anim() ->void:
	#trocar_animação
	if !is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("walk")
			else:
				animation_player.play("idle")
				
func attack() -> void:
	if is_attacking:
		return
	attack_cooldown = 0.8	
	animation_player.play("shoot")
	is_attacking = true

func update_attack_coold(delta)->void:
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")
	
			
func deal_damage_to_enemies() -> void:
	if dynamite_prefab:
		var dynamite = dynamite_prefab.instantiate()
		var direction = Vector2.RIGHT if not animation_player.flip_h else Vector2.LEFT
		
		dynamite.position = position + Vector2(47 if not animation_player.flip_h else -47, 6)
		dynamite.direction = direction
		get_parent().add_child(dynamite)

func _on_animated_sprite_2d_frame_changed():
	if is_attacking && animation_player.get_frame() == 2:
		deal_damage_to_enemies()
