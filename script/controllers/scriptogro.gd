extends CharacterBody2D

@onready var animacao = $AnimatedSprite2D

func _ready() -> void:
		animacao.play()
