extends Node2D
@export var sprite_flip : bool :
	set(value):
		sprite_flip = value
		if value:
			Sprite.flip_h = true
		else:
			Sprite.flip_h = false
@export var puerta_tp: int
@export var mensaje : Control
@export var Sprite: Sprite2D
@onready var mostrar_mensaje : bool = false:
	set(value):
		mostrar_mensaje = value
		if value:
			mensaje.visible = true
		else:
			mensaje.visible = false
func _ready() -> void:
	mostrar_mensaje = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugadores"):
		mostrar_mensaje = true
	

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugadores"):
		mostrar_mensaje = false

func tp():
	var num = "Puerta" +  str(puerta_tp) 
	if puerta_tp == 1 || puerta_tp == 0:
		num = "Puerta"
	var puerta = get_parent().get_node(num)
	var pos = puerta.position
	return pos
