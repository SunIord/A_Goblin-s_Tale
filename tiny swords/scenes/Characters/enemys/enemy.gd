class_name Enemy
extends CharacterBody2D

@export var health: int = 10
@export var death_prefab: PackedScene
@export var gold_prefab = preload("res://scenes/misc/gold.tscn")
var damage_digit_prefab:PackedScene

@onready var gameui:GameUI
@onready var damage_digit_marker = $DamageDigit2d
@onready var hitSfx = $hit_sfx as AudioStreamPlayer

@onready var health_progress_bar: ProgressBar = get_node_or_null("Panel/Life")

func _ready():
	damage_digit_prefab = preload("res://scenes/misc/damage2D.tscn")

func damage(amount:int) -> void:
	hitSfx.play()
	health -= amount

	if health_progress_bar:
		health_progress_bar.value = health

	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self,"modulate",Color.WHITE,0.3)
	
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.position = damage_digit_marker.global_position
	else:
		damage_digit.position = self.position
	
	self.add_child(damage_digit)

	if health <= 0:
		die()

func die()->void:
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position	
		get_parent().add_child(death_object)
	if gold_prefab:
		var gold_object = gold_prefab.instantiate()
		gold_object.position = position
		get_parent().add_child(gold_object)
	var gameui: GameUI = get_tree().root.get_node("level_1/GameUI")
	if gameui.has_method("increase_death"):
		gameui.increase_death()
	queue_free()
