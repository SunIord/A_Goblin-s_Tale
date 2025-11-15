extends CharacterBody2D

@export var speed: float = 3
@export var sword_damage: int = 2
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene
@export_category("Ritual")
@export var super_attack_prefab: PackedScene
@export var ritual_damage:int = 1
@export var ritual_interval: float = 30
@export var gameui: Node = null

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_progress_bar: ProgressBar = %PlayerLife
@onready var basicAttack = preload("res://scenes/systems/basic_attack.tscn")

var input_vector: Vector2 = Vector2.ZERO
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var can_attack: bool = true
var ritual_cooldown: float = 0.0
var time_over: bool = false
var fire_spawned_in_this_attack: bool = false
@export var attack_cooldown: float = 0.8

func _process(delta: float) -> void:
	GameManager.player_position = position
	read_input()

	# ataque
	if Input.is_action_just_pressed("attack_side"):
		attack()
	call_super_attack()

	# animações
	if not is_attacking:
		rotate_sprite()
	play_run_idle_anim()

	# healthbar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

func _physics_process(delta) -> void:
	var target_velocity = input_vector * speed * 100
	if is_attacking:
		target_velocity *= 0.5
	velocity = lerp(velocity, target_velocity, 0.08)
	move_and_slide()

func read_input() -> void:
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.15)
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

# ===============================
#   ATAQUE SINCRONIZADO
# ===============================
func attack() -> void:
	if not can_attack or is_attacking:
		return

	is_attacking = true
	can_attack = false
	fire_spawned_in_this_attack = false

	animation_player.play("Attack_right")

	# Libera o ataque novamente após o cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animation_player.animation == "Attack_right":
		is_attacking = false
		animation_player.play("idle")

func spawn_basic_attack() -> void:
	if fire_spawned_in_this_attack:
		return  # evita múltiplos spawns
	fire_spawned_in_this_attack = true

	var attack_instance = basicAttack.instantiate()
	var attack_direction = Vector2.LEFT if animation_player.flip_h else Vector2.RIGHT
	attack_instance.direction = attack_direction
	attack_instance.position = global_position + attack_direction * 70 + Vector2(0, -35)
	attack_instance.owner = self

	get_tree().root.add_child(attack_instance)
	print("Spawned attack at: ", attack_instance.global_position)

func _on_animated_sprite_2d_frame_changed() -> void:
	if is_attacking:
		if animation_player.get_frame() == 2 and not fire_spawned_in_this_attack:
			spawn_basic_attack()

# ===============================
#   ANIMAÇÃO E MOVIMENTO
# ===============================
func play_run_idle_anim() -> void:
	if not is_attacking and was_running != is_running:
		if is_running:
			animation_player.play("walk")
		else:
			animation_player.play("idle")

func rotate_sprite() -> void:
	if input_vector.x > 0:
		animation_player.flip_h = false
	elif input_vector.x < 0:
		animation_player.flip_h = true

# ===============================
#   DANO, VIDA E MORTE
# ===============================

func damage(amount: int) -> void:
	health -= amount
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	if health <= 0:
		die()

func die() -> void:
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	queue_free()

func heal(amount: int) -> int:
	health = min(max_health, health + amount)
	return health

# ===============================
#   SUPER ATAQUE
# ===============================
func call_super_attack():
	if gameui == null:
		return

	var already_loaded: bool = false
	if gameui.has_method("value_back"):
		already_loaded = gameui.value_back()

	if Input.is_action_just_pressed("super_attack") and already_loaded:
		super_attack()

func super_attack() -> void:
	if super_attack_prefab:
		var flame_spell = super_attack_prefab.instantiate()
		flame_spell.position = Vector2.ZERO
		add_child(flame_spell)
