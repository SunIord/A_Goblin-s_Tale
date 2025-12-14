extends Control
class_name HealthBar

@export var pixels_per_hp: float = 1

func setup(current_hp: int, max_hp: int) -> void:
	self.min_value = 0
	self.max_value = max_hp
	self.value = current_hp
	self.custom_minimum_size.x = max_hp * pixels_per_hp

func set_health(value: int) -> void:
	self.value = value

func set_max_health(value: int) -> void:
	self.max_value = value
	self.custom_minimum_size.x = value * pixels_per_hp
