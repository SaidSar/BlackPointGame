# global_data.gd
extends Node

# Personaje seleccionado
var personaje_seleccionado: String = "Arquero"
# Los personajes     Arquero     Mago      Melee
# Ojo con la mayuscula


var is_loading = false
# Control de niveles
var nivel_actual: int = 0
var nivel_siguiente: int = 1

# Ruta del archivo de guardado
const SAVE_PATH = "user://savegame.save"
@onready var LoadingScreen = preload("res://escenas/Otras cosas/pantalla_carga.tscn")
# Reiniciar progreso (cuando empieza nueva partida)
func reiniciar_progreso():
	nivel_actual = 0
	nivel_siguiente = 1
	print("Progreso reiniciado")

# Completar nivel (cuando termina un nivel)
func completar_nivel():
	nivel_actual += 1
	nivel_siguiente = nivel_actual + 1
	print("Nivel completado: ", nivel_actual)
	
	# Guardar automáticamente al completar nivel
	guardar_partida()

# Obtener ruta del siguiente nivel
func get_ruta_nivel_siguiente() -> String:
	match nivel_siguiente:
		1:
			return "res://escenas/Nivel/CatacumbasP1.tscn"  # Tu nivel 1
		2:
			return "res://escenas/Nivel/valle_encantado.tscn" # Tu nivel 2
		3:
			return "res://escenas/Nivel/valle_encantado.tscn" # Tu nivel 3
		_:
			return "res://scenes/main_menu.tscn"  # Si terminó todos

#cambiar Nivel
func Cambiar_nivel(path: String):
	if is_loading:
		return
	is_loading = true
	LoadingScreen.show_screen()
	
	await get_tree().create_timer(0.4).timeout   # pequeña espera para mostrar el loading
	var new_scene = load(path).instantiate()
	get_tree().current_scene.free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	LoadingScreen.hide_screen()
	is_loading = false

# ===== FUNCIONES DE GUARDADO =====

# Guardar partida
func guardar_partida():
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if save_file:
		var save_data = {
			"personaje": personaje_seleccionado,
			"nivel_actual": nivel_actual,
			"nivel_siguiente": nivel_siguiente
		}
		
		var json_string = JSON.stringify(save_data)
		save_file.store_line(json_string)
		save_file.close()
		
		print("Partida guardada - Nivel: ", nivel_actual, " Personaje: ", personaje_seleccionado)
		return true
	else:
		print("Error al guardar partida")
		return false

# Cargar partida
func cargar_partida():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No existe archivo de guardado")
		return false
	
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if save_file:
		var json_string = save_file.get_line()
		save_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var save_data = json.data
			
			personaje_seleccionado = save_data.get("personaje", "arquero")
			nivel_actual = save_data.get("nivel_actual", 0)
			nivel_siguiente = save_data.get("nivel_siguiente", 1)
			
			print("Partida cargada - Nivel: ", nivel_actual, " Personaje: ", personaje_seleccionado)
			return true
		else:
			print("Error al parsear JSON")
			return false
	else:
		print("Error al abrir archivo de guardado")
		return false

# Verificar si existe partida guardada
func tiene_partida_guardada() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# Borrar partida guardada (opcional, por si quieres un botón para borrar)
func borrar_partida():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Partida eliminada")
		return true
	return false
