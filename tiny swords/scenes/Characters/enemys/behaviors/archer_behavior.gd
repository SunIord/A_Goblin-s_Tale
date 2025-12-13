extends Node2D

@export var speed: float = 1.2
@export var attack_range: float = 600.0  # Aumente para 600
@export var MIN_DISTANCE: float = 100.0  # Torna exportável
@export var attack_cooldown_time: float = 1.5

# USA @onready para referências automáticas
@onready var enemy: Node2D = get_parent()  # ← Parent é o Archer
@onready var animation_player: AnimatedSprite2D = enemy.get_node("AnimatedSprite2D")
@onready var arrow_spawn: Marker2D = enemy.get_node("ArrowSpawn")

# ESTADOS
enum State { WALK, SHOOT }
var current_state: State = State.WALK
var is_shooting: bool = false
var attack_cooldown: float = 0.0
var last_player_pos: Vector2


func _ready():
	print("=== ARCHER BEHAVIOR INICIANDO ===")
	print("Parent: ", get_parent().name if get_parent() else "NULO")
	
	enemy = get_parent()
	if not enemy:
		push_error("❌ ERRO: Parent (enemy) é nulo!")
		return
	
	print("Enemy class: ", enemy.get_class())
	print("Enemy script: ", enemy.get_script())
	
	# Tenta encontrar ArrowSpawn
	arrow_spawn = enemy.get_node("ArrowSpawn")
	if arrow_spawn:
		print("✅ ArrowSpawn encontrado: ", arrow_spawn.name)
		print("   Posição local: ", arrow_spawn.position)
	else:
		print("❌ ArrowSpawn NÃO encontrado!")
		# Lista todos os filhos para debug
		print("   Filhos do enemy:")
		for child in enemy.get_children():
			print("     - ", child.name, " (", child.get_class(), ")")
	
	# Continuação normal...

func _process(delta):
	if GameManager.is_game_over:
		return
	
	attack_cooldown = max(attack_cooldown - delta, 0.0)
	rotate_towards_player()
	update_state(delta)

func update_state(delta):
	var player_pos = GameManager.player_position
	var distance = enemy.position.distance_to(player_pos)
	
	# DEBUG: Mostra estado atual
	if Engine.get_frames_drawn() % 60 == 0:
		print("Archer - Estado: ", State.keys()[current_state], 
			  " | Distância: ", int(distance),
			  " | Cooldown: ", attack_cooldown,
			  " | Atirando: ", is_shooting)
	
	# REGRAS DE TRANSIÇÃO
	match current_state:
		State.WALK:
			# Se player está no alcance E não está muito perto → ATIRA
			if distance <= attack_range and distance > MIN_DISTANCE and attack_cooldown <= 0:
				switch_state(State.SHOOT)
		
		State.SHOOT:
			# Se player saiu do alcance OU está muito perto → ANDA
			if distance > attack_range or distance <= MIN_DISTANCE or attack_cooldown > 0:
				switch_state(State.WALK)

func switch_state(new_state: State):
	if current_state == new_state:
		return
	
	print("Mudando estado: ", State.keys()[current_state], " → ", State.keys()[new_state])
	current_state = new_state
	
	match current_state:
		State.WALK:
			is_shooting = false
			enemy.velocity = Vector2.ZERO
			play_walk_anim()
		
		State.SHOOT:
			start_shooting_sequence()

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
			enemy.velocity = Vector2.ZERO  # Fica parado atirando
	
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

func start_shooting_sequence():
	if is_shooting or attack_cooldown > 0:
		return
	
	is_shooting = true
	last_player_pos = GameManager.player_position
	
	print("Iniciando sequência de tiro...")
	
	# VERIFICA A CADA FRAME se ainda pode atirar
	for i in range(10):  # Timeout de segurança
		var current_distance = enemy.position.distance_to(GameManager.player_position)
		if current_distance > attack_range or current_distance <= MIN_DISTANCE:
			print("Cancelado: Player saiu do alcance")
			switch_state(State.WALK)
			return
		await get_tree().process_frame
	
	# Toca animação de tiro
	if animation_player.sprite_frames.has_animation("shoot"):
		animation_player.play("shoot")
		
		# Monitora frames para spawnar flecha no frame 6
		for frame in range(8):  # Para cada frame esperado
			await animation_player.frame_changed
			if animation_player.frame == 6 and is_shooting:
				# Verificação FINAL antes de atirar
				var final_check = enemy.position.distance_to(GameManager.player_position)
				if final_check <= attack_range and final_check > MIN_DISTANCE:
					spawn_arrow()
				else:
					print("Cancelado no último instante")
					animation_player.stop()
					switch_state(State.WALK)
					return
		
		# Aguarda fim da animação
		await animation_player.animation_finished
	else:
		# Fallback: atira sem animação
		await get_tree().create_timer(0.5).timeout
		if is_shooting:
			spawn_arrow()
	
	# Finaliza
	is_shooting = false
	attack_cooldown = attack_cooldown_time
	
	# Decide próximo estado
	update_state(0.0)

func spawn_arrow():
	print("=== SPAWN ARROW DEBUG ===")
	print("Arrow Prefab: ", enemy.arrow_prefab)
	print("Archer Global Pos: ", enemy.global_position)
	print("ArrowSpawn Global Pos: ", arrow_spawn.global_position)
	print("ArrowSpawn Local Pos: ", arrow_spawn.position)
	print("Player pos: ", GameManager.player_position)
	
	if not enemy.arrow_prefab:
		print("❌ ERRO: Arrow Prefab não carregado!")
		return
	
	var arrow = enemy.arrow_prefab.instantiate()
	print("Arrow instanciada: ", arrow)
	
	# 🔴 CORREÇÃO CRÍTICA: Usar global_position CORRETAMENTE
	arrow.global_position = arrow_spawn.global_position
	
	# 🔴 CORREÇÃO: Direção baseada na posição GLOBAL
	var target_pos = GameManager.player_position
	var direction = (target_pos - arrow_spawn.global_position).normalized()
	arrow.direction = direction
	
	print("Direção calculada: ", direction)
	print("Distância arqueiro-player: ", enemy.global_position.distance_to(target_pos))
	print("Posição final da flecha: ", arrow.global_position)
	
	# Adiciona na cena (nível)
	var level = get_tree().get_root().get_node("Level")  # Ajuste para o nome da sua cena principal
	if level:
		level.add_child(arrow)
	else:
		get_parent().get_parent().add_child(arrow)
	
	print("✅ Flecha adicionada à cena na posição: ", arrow.global_position)
