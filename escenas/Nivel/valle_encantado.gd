extends Node2D
func _ready() -> void:
	var character_scene = load("res://escenas/Jugadores/%s.tscn" % GlobalData.personaje_seleccionado)
	var player = character_scene.instantiate()
	add_child(player)
	player.position = Vector2(0,0)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugadores"):
		var n = GlobalData.get_ruta_nivel_actual()
		GlobalData.Cambiar_nivel(n)
