extends Area2D

@export var speed: float = 200
@export var max_distance: float = 200  # distância máxima que o ataque percorre
var direction: Vector2 = Vector2.RIGHT
var start_position: Vector2

func _ready():
	start_position = global_position
	$AnimatedSprite2D.play("attack_loop")
	set_process(true)

func _process(delta):
	position += direction * speed * delta
	
	# verifica distância percorrida
	if global_position.distance_to(start_position) >= max_distance:
		queue_free()
