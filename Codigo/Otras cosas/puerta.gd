extends Node2D
@export var mensaje : Control
var mostrar_mensaje : bool = true:
	set(value):
		mostrar_mensaje = value
		if value:
			mensaje.visible = true
		else:
			mensaje.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugadores"):
		mostrar_mensaje = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugadores"):
		mostrar_mensaje = false
