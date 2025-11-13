extends Control

@onready var animacion = $AnimationPlayer
@onready var tiempo = $Timer

func _ready():
	animacion.play("carga")
	tiempo.start()
	tiempo.timeout
	#get_tree().change_scene_to_file("res://escenas/Otras cosas/pruebas.tscn")
	pass
	
