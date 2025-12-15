extends Resource
class_name PowerUpData

@export var id: String
@export var title: String
@export var description: String
@export var price: int
@export var icon: Texture2D

var data

func setup(power_data: PowerUpData) -> void:
	data = power_data
	print("Configurando card - ID:", data.id, " Tipo:", typeof(data.id))
	# ... resto do código
