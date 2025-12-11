extends Control

func salir():
	GlobalData.Cambiar_nivel("res://escenas/Otras cosas/main_menu.tscn")

func Reintentar():
	var n = GlobalData.get_ruta_nivel_actual()
	GlobalData.Cambiar_nivel(n)


func _on_salir_pressed() -> void:
	salir()


func _on_reintentar_pressed() -> void:
	Reintentar()
