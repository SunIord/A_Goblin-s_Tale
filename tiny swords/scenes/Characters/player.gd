extends CharacterBody2D

signal super_attack_used
signal cutscene_path_finished

@export var death_prefab: PackedScene

@export_category("Ritual")
@export var super_attack_prefab: PackedScene
@export var ritual_damage:int = 1
@export var ritual_interval: float = 30
@export var has_firefly: bool = false

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: HealthBar = $HealthBar
@onready var basicAttack = preload("res://scenes/systems/basic_attack.tscn")
@onready var attackSfx = $attack_sfx as AudioStreamPlayer
@onready var hitSfx = $hit_sfx as AudioStreamPlayer


var input_vector: Vector2 = Vector2.ZERO
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var can_attack: bool = true
var ritual_cooldown: float = 0.0
var time_over: bool = false
var fire_spawned_in_this_attack: bool = false
var gameui: Node = null
@export var attack_cooldown: float = 0.8

var current_priority := 1

# -------------------------------------------------
# CUTSCENE
# -------------------------------------------------
var in_cutscene: bool = false
var cutscene_targets: Array[Vector2] = []
# -------------------------------------------------

func _ready() -> void:
	gameui = get_tree().get_first_node_in_group("game_ui")
	GameManager.current_health = GameManager.max_health
	health_bar.setup(GameManager.current_health, GameManager.max_health)


func _process(delta: float) -> void:
	GameManager.player_position = position

	if not in_cutscene:
		read_input()
	else:
		input_vector = Vector2.ZERO
		is_running = true
		current_priority = 2
		if animation_player.animation != "walk":
			animation_player.play("walk")

	if Input.is_action_just_pressed("attack_side") and not in_cutscene:
		attack()

	call_super_attack()

	if not is_attacking:
		rotate_sprite()
	play_run_idle_anim()


func _physics_process(delta) -> void:
	var target_velocity: Vector2

	if in_cutscene:
		_process_cutscene_movement()
	else:
		target_velocity = input_vector * GameManager.move_speed * 100
		if is_attacking:
			target_velocity *= 0.5
		velocity = lerp(velocity, target_velocity, 0.08)

	move_and_slide()


# -------------------------------------------------
# CUTSCENE MOVEMENT
# -------------------------------------------------
func _process_cutscene_movement():
	if cutscene_targets.is_empty():
		in_cutscene = false
		velocity = Vector2.ZERO
		emit_signal("cutscene_path_finished")
		return

	var target := cutscene_targets[0]
	var dir := target - global_position

	if dir.length() < 5:
		cutscene_targets.pop_front()
		return

	var target_velocity = dir.normalized() * GameManager.move_speed * 100
	velocity = lerp(velocity, target_velocity, 0.1)


# -------------------------------------------------
# INPUT / MOVIMENTO
# -------------------------------------------------
func read_input() -> void:
	input_vector = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down", 0.15
	)
	was_running = is_running
	is_running = not input_vector.is_zero_approx() or velocity.length() > 60


# -------------------------------------------------
# ATAQUE
# -------------------------------------------------
func attack() -> void:
	if not can_attack or is_attacking:
		return

	attackSfx.play()
	is_attacking = true
	can_attack = false
	fire_spawned_in_this_attack = false
	current_priority = 3
	animation_player.play("Attack_right")

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if animation_player.animation == "Attack_right":
		is_attacking = false
		current_priority = 0


func spawn_basic_attack() -> void:
	if fire_spawned_in_this_attack:
		return

	fire_spawned_in_this_attack = true

	var attack_instance = basicAttack.instantiate()
	var is_upgraded = GameManager.is_powerup_purchased("damage_upgrade") \
		or GameManager.is_powerup_purchased("2")
	attack_instance.set_is_upgraded(is_upgraded)

	var attack_direction = Vector2.LEFT if animation_player.flip_h else Vector2.RIGHT
	attack_instance.direction = attack_direction
	attack_instance.position = global_position + attack_direction * 70 + Vector2(0, -35)
	attack_instance.owner = self

	get_tree().root.add_child(attack_instance)


func _on_animated_sprite_2d_frame_changed() -> void:
	if is_attacking and animation_player.get_frame() == 2 and not fire_spawned_in_this_attack:
		spawn_basic_attack()


# -------------------------------------------------
# ANIMAÇÃO
# -------------------------------------------------
func play_run_idle_anim() -> void:
	if is_attacking:
		return

	if is_running:
		if current_priority < 2:
			current_priority = 2
			animation_player.play("walk")
		return

	current_priority = 1
	animation_player.play("idle")


func rotate_sprite() -> void:
	if input_vector.x > 0:
		animation_player.flip_h = false
	elif input_vector.x < 0:
		animation_player.flip_h = true


# -------------------------------------------------
# VIDA
# -------------------------------------------------
func damage(amount: int) -> void:
	GameManager.current_health -= amount
	health_bar.set_health(GameManager.current_health)
	hitSfx.play()

	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

	if GameManager.current_health <= 0:
		die()

func die() -> void:
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	queue_free()


func heal(amount: int) -> void:
	GameManager.current_health = min(
		GameManager.max_health,
		GameManager.current_health + amount
	)
	health_bar.set_health(GameManager.current_health)


# -------------------------------------------------
# SUPER ATTACK
# -------------------------------------------------
func spawn_super_attack() -> void:
	if super_attack_prefab == null:
		return
	var atk = super_attack_prefab.instantiate()
	add_child(atk)
	emit_signal("super_attack_used")


func call_super_attack():
	if gameui == null or in_cutscene:
		return

	var is_ready = false
	if gameui.has_method("is_super_ready"):
		is_ready = gameui.is_super_ready()

	if Input.is_action_just_pressed("super_attack") and is_ready:
		spawn_super_attack()


# -------------------------------------------------
# API PÚBLICA DE CUTSCENE
# -------------------------------------------------
func start_cutscene(targets: Array[Vector2]):
	cutscene_targets = targets.duplicate()
	in_cutscene = true
