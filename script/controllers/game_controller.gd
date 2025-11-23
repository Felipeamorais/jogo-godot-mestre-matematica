extends Node

@export var quiz: QuizTheme
@export var color_right: Color
@export var color_wrong: Color

var buttons: Array[Button]
var index: int
var correct: int
var vida: int
var vidaboss: int
var mana: int

var current_quiz: QuizQuestion:
	get: return quiz.theme[index]

@onready var question_texts: Label = $"Content/Questão/Label"
@onready var cronometro: Timer = $Timer
@onready var vidatexto = $VidaTexto
@onready var correcttexto = $Content/Acertos
@onready var vidabosstexto = $VidaBoss
@onready var manatexto = $ManaTexto
@onready var animacaoplayer = $Player/AnimatedSprite2D
@onready var animacaoogro = $ogro/AnimatedSprite2D

func _ready() -> void:
	correct = 0
	vida = 3
	vidaboss = 3
	mana = 0
	
	for button in $Content/Resposta.get_children():
		buttons.append(button)
		
	randomize_array(quiz.theme)
	load_quiz()

func load_quiz() -> void:
	animacaoogro.play()
	animacaoplayer.play("parado")
	vidabosstexto.text = "Vida do Boss: " + str(vidaboss)
	correcttexto.text = "Acertos: " + str(correct)
	vidatexto.text = "Vida: " + str(vida)
	manatexto.text = "Mana: " + str(mana)

	if vidaboss == 0:
		get_tree().change_scene_to_file("res://cenamais.tscn")

	cronometro.start()
	question_texts.text = quiz.theme[index].question_info
	
	var options = randomize_array(current_quiz.options)
	for i in buttons.size():
		buttons[i].text = options[i]
		buttons[i].pressed.connect(_buttons_answer.bind(buttons[i]))
		
func _buttons_answer(button) -> void:
	if quiz.theme[index].correct == button.text:
		correct += 1
		mana += 1
		print("Acertos:", correct)
		print("Mana:", mana)
		button.modulate = color_right
		dar_dano()
		await get_tree().create_timer(1).timeout
		_next_question()
	else:
		button.modulate = color_wrong
		await get_tree().create_timer(1).timeout
		if vida <= 0:
			_game_over()
		else:
			_next_question()
			
func dar_dano() -> void:
	if mana == 3:
		animacaoplayer.play("dardano")
		vidaboss -= 1
		mana = 0
	
	vidabosstexto.text = "Vida do Boss: " + str(vidaboss)
	vidatexto.text = "Vida: " + str(vida)
	correcttexto.text = "Acertos: " + str(correct)
	manatexto.text = "Mana: " + str(mana)

	if vidaboss <= 0:
		get_tree().change_scene_to_file("res://cenamais.tscn")

func _next_question() -> void:
	for bt in buttons:
		bt.pressed.disconnect(_buttons_answer)
		
	for bt in buttons:
		bt.modulate = Color.WHITE
		
	index += 1
	if index >= quiz.theme.size():
		index = 0 
	load_quiz()
	
func _on_timer_timeout() -> void:
	if correct < 9:
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
