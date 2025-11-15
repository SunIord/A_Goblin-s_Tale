class_name Enemy
extends CharacterBody2D

@export var health: int = 10
@export var death_prefab: PackedScene
var damage_digit_prefab:PackedScene

@onready var gameui:GameUI

@onready var damage_digit_marker = $DamageDigit2d

func _ready():
	damage_digit_prefab = preload("res://scenes/misc/damage2D.tscn")

func damage(amount:int) -> void:
	health -= amount
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self,"modulate",Color.WHITE,0.3)
	
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		print(1)
		damage_digit.position = damage_digit_marker.global_position
		
	else:
		print(2, position, global_position)
		damage_digit.position = self.position
		print(damage_digit.position)
	self.add_child(damage_digit)
	if health <= 0:
		die()
func die()->void:
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position	
		get_parent().add_child(death_object)
	var world = self.get_parent()
	var gameui:GameUI = world.get_node("gameui")
	if gameui.has_method("increase_death"):
		gameui.increase_death()
	queue_free()
