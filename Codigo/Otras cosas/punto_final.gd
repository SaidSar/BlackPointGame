extends Node2D
@export var sprite_flip : bool :
	set(value):
		sprite_flip = value
		if value:
			Sprite.flip_h = true
		else:
			Sprite.flip_h = false
@export var nivel_siguiente: int
@export var mensaje : Control
@export var Sprite: Sprite2D
@onready var mostrar_mensaje : bool = false:
	set(value):
		mostrar_mensaje = value
		if value:
			mensaje.visible = true
		else:
			mensaje.visible = false
@onready var jugador 
func _ready() -> void:
	mostrar_mensaje = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugadores"):
		mostrar_mensaje = true
		jugador = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugadores"):
		mostrar_mensaje = false
		jugador = null

func tp():
	if jugador != null:
		GlobalData.completar_nivel()
		var n = GlobalData.get_ruta_nivel_siguiente()
		GlobalData.Cambiar_nivel(n)
		pass
	return 0
