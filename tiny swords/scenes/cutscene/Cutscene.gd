extends Control

@onready var text_label: RichTextLabel = $RichTextLabel
@onready var clickBtn = $"../button_click" as AudioStreamPlayer

var lines := [
	"Olá, viajante...",
	"Bem-vindo ao reino de 'A Goblin's Tale'!",
	"Há muitas gerações, o reino dos cavaleiros e o dos goblins viviam em paz graças a um antigo tratado que garantia terras e segurança para ambos. Com o tempo, porém, a ambição e o preconceito dos cavaleiros cresceram, e eles romperam o acordo, invadindo e tomando as terras dos goblins à força.", 
	"Anos depois desse rompimento, um goblin simples viu sua vida desmoronar quando sua esposa e seu melhor amigo desapareceram sem deixar rastros. Desesperado e sem pistas, ele parte em uma jornada solitária em busca dos dois, cruzando florestas perigosas, ruínas de antigas vilas goblins e fronteiras proibidas entre os reinos.",
	"Durante a viagem, o goblin descobre que sua vila foi atacada por uma horda de cavaleiros e que sua esposa e seu amigo foram sequestrados. Agora, ele não está apenas em busca dos entes queridos: precisa desvendar a verdade por trás do ataque, enfrentar o reino que traiu o tratado e se vingar dos cavaleiros que destruíram sua vida."
]
var current_line := 0

func _ready() -> void:
	_show_line()

func _show_line() -> void:
	text_label.visible_ratio = 0.0
	text_label.text = lines[current_line]
	var tween := create_tween()
	tween.tween_property(text_label, "visible_ratio", 1.0, 2.0)

func _on_NextButton_pressed() -> void:
	clickBtn.play()
	if current_line < lines.size() - 1:
		$RichTextLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_FILL
		current_line += 1
		_show_line()
	else:
		queue_free()
		get_tree().change_scene_to_file("res://scenes/Areas/Hub.tscn")
