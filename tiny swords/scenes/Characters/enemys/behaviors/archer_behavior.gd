extends Node2D

@export var speed: float = 1.2
@export var attack_range: float = 600.0
@export var MIN_DISTANCE: float = 100.0
@export var attack_cooldown_time: float = 1.5
@export var HYSTERESIS_MARGIN: float = 20.0  # Zona morta para evitar oscilações

@onready var enemy: Node2D = get_parent()
@onready var animation_player: AnimatedSprite2D = enemy.get_node("AnimatedSprite2D")
@onready var arrow_spawn: Marker2D = enemy.get_node("ArrowSpawn")

enum State { WALK, SHOOT }
var current_state: State = State.WALK
var is_shooting: bool = false
var attack_cooldown: float = 0.0
var last_player_pos: Vector2
var should_stop_shooting: bool = false  # Flag simples para parar o tiro
var is_in_shooting_cycle: bool = false  # Para evitar múltiplos ciclos

func _ready():
	print("🏹 Archer Behavior iniciado")
	
	if not arrow_spawn:
		push_error("❌ ArrowSpawn não encontrado!")

func _process(delta):
	if GameManager.is_game_over:
		return
	
	attack_cooldown = max(attack_cooldown - delta, 0.0)
	rotate_towards_player()
	update_state()

func update_state():
	var player_pos = GameManager.player_position
	var distance = enemy.position.distance_to(player_pos)
	
	# Regras de transição COM HYSTERESIS
	match current_state:
		State.WALK:
			# Para entrar no estado SHOOT, precisa estar BEM dentro do alcance
			if distance <= (attack_range - HYSTERESIS_MARGIN) and distance > MIN_DISTANCE and attack_cooldown <= 0:
				switch_state(State.SHOOT)
		
		State.SHOOT:
			# Para sair do estado SHOOT, precisa estar BEM fora do alcance
			if distance > (attack_range + HYSTERESIS_MARGIN) or distance <= (MIN_DISTANCE - HYSTERESIS_MARGIN):
				switch_state(State.WALK)

func switch_state(new_state: State):
	if current_state == new_state:
		return
	
	current_state = new_state
	
	match current_state:
		State.WALK:
			# Sinaliza para parar o tiro
			should_stop_shooting = true
			is_shooting = false
			enemy.velocity = Vector2.ZERO
			play_walk_anim()
		
		State.SHOOT:
			# Inicia comportamento de tiro
			should_stop_shooting = false
			is_shooting = true
			enemy.velocity = Vector2.ZERO
			
			# Inicia o ciclo de tiro se não estiver já em um
			if not is_in_shooting_cycle:
				start_shooting_cycle()

func rotate_towards_player():
	var player_pos = GameManager.player_position
	var direction = player_pos - enemy.position
	
	if direction.x > 0:
		animation_player.flip_h = false
	elif direction.x < 0:
		animation_player.flip_h = true

func _physics_process(delta):
	match current_state:
		State.WALK:
			move_towards_player()
		State.SHOOT:
			enemy.velocity = Vector2.ZERO
	
	enemy.move_and_slide()

func move_towards_player():
	var player_pos = GameManager.player_position
	var diff = player_pos - enemy.position
	var distance = diff.length()
	
	if distance > MIN_DISTANCE:
		var input_vector = diff.normalized()
		var target_velocity = input_vector * speed * 100.0
		enemy.velocity = lerp(enemy.velocity, target_velocity, 0.25)
	else:
		enemy.velocity = Vector2.ZERO

func play_walk_anim():
	if animation_player.sprite_frames.has_animation("walk"):
		animation_player.play("walk")

func start_shooting_cycle():
	if is_in_shooting_cycle:
		return  # Já está em um ciclo
	
	is_in_shooting_cycle = true
	
	# Inicia a coroutine
	_shooting_behavior()

func _shooting_behavior():
	# Esta função executa como uma coroutine
	while current_state == State.SHOOT and not should_stop_shooting:
		# Verifica se ainda pode atirar
		var player_pos = GameManager.player_position
		var distance = enemy.position.distance_to(player_pos)
		
		if distance > attack_range or distance <= MIN_DISTANCE:
			break
		
		# Executa um ciclo de animação + disparo
		await execute_single_shot()
		
		# Pequena pausa entre ciclos
		if current_state == State.SHOOT and not should_stop_shooting:
			await get_tree().create_timer(0.1).timeout
	
	# Limpa o flag quando terminar
	is_in_shooting_cycle = false

func execute_single_shot():
	if current_state != State.SHOOT or should_stop_shooting:
		return
	
	# Verifica alcance
	var player_pos = GameManager.player_position
	var distance = enemy.position.distance_to(player_pos)
	
	if distance > attack_range or distance <= MIN_DISTANCE:
		return
	
	# Toca animação de tiro
	if animation_player.sprite_frames.has_animation("shoot"):
		animation_player.play("shoot")
		
		var has_shot = false
		var max_frames = animation_player.sprite_frames.get_frame_count("shoot")
		var frame_count = 0
		
		# Monitora a animação
		while animation_player.is_playing() and current_state == State.SHOOT and not should_stop_shooting:
			var current_frame = animation_player.frame
			await animation_player.frame_changed
			
			frame_count += 1
			
			# FRAME 6: DISPARA!
			if animation_player.frame == 6 and not has_shot:
				# Verificação final
				var current_distance = enemy.position.distance_to(GameManager.player_position)
				if current_distance <= attack_range and current_distance > MIN_DISTANCE:
					spawn_arrow()
					has_shot = true
				else:
					animation_player.stop()
					return
			
			# Completa um ciclo
			if frame_count >= max_frames:
				break
		
		# Para a animação
		if animation_player.is_playing():
			animation_player.stop()
	
	else:
		# Fallback sem animação
		await get_tree().create_timer(1.0).timeout
		
		if current_state == State.SHOOT and not should_stop_shooting:
			var current_distance = enemy.position.distance_to(GameManager.player_position)
			if current_distance <= attack_range and current_distance > MIN_DISTANCE:
				spawn_arrow()

func spawn_arrow():
	if not enemy.arrow_prefab or not arrow_spawn:
		return
	
	var arrow = enemy.arrow_prefab.instantiate()
	arrow.global_position = arrow_spawn.global_position
	var target_pos = GameManager.player_position
	arrow.direction = (target_pos - arrow_spawn.global_position).normalized()
	
	var level = get_tree().get_root().get_node("Level")
	if level:
		level.add_child(arrow)
	else:
		get_parent().get_parent().add_child(arrow)
