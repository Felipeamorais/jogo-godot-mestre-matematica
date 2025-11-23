extends Node

@export var quiz: QuizTheme
@export var color_right: Color
@export var color_wrong: Color

var buttons: Array[Button]
var index: int
var correct: int
var vida: int
var vidaboss: int
var mana : int

var current_quiz: QuizQuestion:
	get: return quiz.theme[index]

@onready var question_texts: Label = $"Content/Questão/Label"
@onready var cronometro : Timer = $Timer
@onready var vidatexto = $VidaTexto
@onready var correcttexto = $Content/Acertos
@onready var vidabosstexto = $VidaBoss
@onready var manatexto = $ManaTexto
@onready var animacaoplayer = $Player/AnimatedSprite2D
@onready var animacaomais = $Mais/AnimatedSprite2D


func _ready() -> void:
	correct = 0
	mana = 0
	load_stats()       # ← Carrega vida e vidaboss do txt

	for button in $Content/Resposta.get_children():
		buttons.append(button)
		
	randomize_array(quiz.theme)
	load_quiz()


# ============================================================
#   FUNÇÃO PARA CARREGAR O stats.txt
# ============================================================
func load_stats():
	var file = FileAccess.open("res://stats.txt", FileAccess.READ)

	if file == null:
		push_error("❌ ERRO: stats.txt não encontrado!")
		vida = 3
		vidaboss = 3
		return

	while file.get_position() < file.get_length():
		var line = file.get_line().strip_edges()

		if line == "" or not line.contains("="):
			continue

		var parts = line.split("=")
		var key = parts[0].strip_edges()
		var val = parts[1].strip_edges()

		if val.is_valid_int():
			val = int(val)

		if key == "vida":
			vida = val
		elif key == "vidaboss":
			vidaboss = val

	file.close()
# ============================================================


func load_quiz() -> void:
	cronometro.start()
	animacaomais.play("parado")
	animacaoplayer.play("parado")

	vidabosstexto.text = "Vida do Boss: " + str(vidaboss)
	correcttexto.text = "Acertos: " + str(correct)
	vidatexto.text = "Vida: " + str(vida)
	manatexto.text = "Mana: " + str(mana)

	if vidaboss == 0:
		get_tree().change_scene_to_file("res://combatemenos.tscn")

	question_texts.text = quiz.theme[index].question_info
	
	var options = randomize_array(current_quiz.options)
	for i in buttons.size():
		buttons[i].text = options[i]
		buttons[i].pressed.connect(_buttons_answer.bind(buttons[i]))
		

func _buttons_answer(button) -> void:
	
	if quiz.theme[index].correct == button.text:
		correct += 1
		mana += 1
		button.modulate = color_right
		dar_dano()
		await get_tree().create_timer(1).timeout
		_next_question()
	else:
		button.modulate = color_wrong
		animacaomais.play("dano")
		animacaoplayer.play("tomanocu")
		vida -= 1
		await get_tree().create_timer(1).timeout

		if vida <= 0:
			_game_over()
		else:
			_next_question()
			

func dar_dano() -> void:
	if mana == 3:
		animacaoplayer.play("dardano")
		animacaomais.play("tomano")
		vidaboss -= 1
		mana = 0
		

func _next_question() -> void:
	for bt in buttons:
		bt.pressed.disconnect(_buttons_answer)
		
	for bt in buttons:
		bt.modulate = Color.WHITE
		
	index += 1
	load_quiz()
	

func _on_timer_timeout() -> void:
	if correct < 9:
		vida -= 1

		if vida <= 0:
			_game_over()
		else:
			_next_question()
			

func randomize_array(array: Array) -> Array:
	var array_temp := array
	array_temp.shuffle()
	return array_temp


func _game_over() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://gameover.tscn")
