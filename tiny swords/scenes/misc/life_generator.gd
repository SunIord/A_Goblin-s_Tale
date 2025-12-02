extends Sprite2D

@export var generation_amount: int = 10

@onready var Area2d:Area2D = $Area2D
@onready var can_eat:bool = true

func able_to_eat()-> void:
	can_eat = true

func _on_area_2d_body_entered(body):
	if can_eat: 
		if body.name == "player":
			body.heal(generation_amount)
			queue_free()	

#func _on_animation_player_animation_finished(anim_name):
	#can_eat = true# Replace with function body.
