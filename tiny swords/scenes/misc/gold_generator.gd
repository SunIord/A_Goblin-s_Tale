extends Sprite2D

@export var generation_amount: int = 10

@onready var Area2d:Area2D = $Area2D
@onready var can_collect:bool = false

func able_to_collect()-> void:
	can_collect = true

func _on_area_2d_body_entered(body):
	if can_collect: 
		if body.name == "player":
			body.collect(generation_amount)
			queue_free()	

func _on_animation_player_animation_finished(anim_name):
	can_collect = true# Replace with function body.
