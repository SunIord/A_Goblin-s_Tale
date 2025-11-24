extends Node2D

@export var speed: float = 1.5
@onready var input_vector: Vector2


var enemy: Sheep
var seeing_area: Area2D 
var animation_player: AnimatedSprite2D 
var is_following: bool
var is_attacking: bool


func _ready():
	enemy = get_parent()
	animation_player = enemy.get_node("AnimatedSprite2D")
	seeing_area = enemy.get_node("Area2D")

func _process(delta):
	play_run_idle_anim()
	rotate_sprite()
	
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
	#trocar_animação
			if is_following && !is_attacking:
				animation_player.play("walk")
			elif !is_following:
				animation_player.play("idle")
				
func move(input_vector:Vector2)-> void:
	var target_velocity = input_vector * speed * 100.0
	enemy.velocity = lerp(enemy.velocity,target_velocity,0.08)

func stop(input_vector:Vector2)-> void:
	var target_velocity = input_vector * Vector2(0,0)
	enemy.velocity = lerp(enemy.velocity,target_velocity,0.08)


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		is_following = false
		stop(input_vector)# Replace with function body.
