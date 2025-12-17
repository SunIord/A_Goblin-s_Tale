extends AudioStreamPlayer

func _ready():
	# Conecta o sinal: quando esta música ACABAR, chame a função _on_finished
	connect("finished", Callable(self, "_on_finished"))
	# Inicia a música pela primeira vez (se for para tocar automaticamente)
	# play_music()

func play_music():
	if not playing:
		play()

func _on_finished():
	# Esta função é chamada automaticamente quando a música termina
	play_music()  # Toca novamente
