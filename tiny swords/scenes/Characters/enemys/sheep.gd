class_name Sheep
extends Node2D

@export var health: int = 10
@export var meat_prefab: PackedScene

func damage(amount:int) -> void:
	health -= amount
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self,"modulate",Color.WHITE,0.3)
	if health <= 0:
		die()
	print("Inimigo recebeu dano de ", amount, ". A vida total é de ", health)

func die()->void:
	if meat_prefab:
		var meat_object = meat_prefab.instantiate()
		meat_object.position = Vector2(position.x,position.y + 10)	
		get_parent().add_child(meat_object)
	queue_free()
		
	
