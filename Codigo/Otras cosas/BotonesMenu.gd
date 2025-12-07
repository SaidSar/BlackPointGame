extends VBoxContainer

var boton_nueva_partida: Button
var boton_continuar: Button
var boton_opciones: Button
var boton_salir: Button

func _ready():
	# Buscar botones automáticamente por nombre
	boton_nueva_partida = buscar_boton("botonNuevaPartida")
	boton_continuar = buscar_boton("botonContinuar")
	boton_opciones = buscar_boton("botonOpciones")
	boton_salir = buscar_boton("botonSalir")
	
	# Conectar señales
	if boton_nueva_partida:
		boton_nueva_partida.pressed.connect(_on_nueva_partida_pressed)
	if boton_continuar:
		boton_continuar.pressed.connect(_on_continuar_pressed)
	if boton_opciones:
		boton_opciones.pressed.connect(_on_opciones_pressed)
	if boton_salir:
		boton_salir.pressed.connect(_on_salir_pressed)
	
	verificar_partida_guardada()

func buscar_boton(nombre: String) -> Button:
	return buscar_recursivo(self, nombre) as Button

func buscar_recursivo(nodo: Node, nombre_buscado: String) -> Node:
	if nodo.name == nombre_buscado:
		return nodo
	
	for hijo in nodo.get_children():
		var resultado = buscar_recursivo(hijo, nombre_buscado)
		if resultado:
			return resultado
	
	return null

func _on_nueva_partida_pressed():
	print("Iniciando nueva partida...")
	get_tree().change_scene_to_file("res://escenas/Otras cosas/seleccion_personaje.tscn")

func _on_continuar_pressed():
	print("Continuando partida guardada...")
	
	if GlobalData.tiene_partida_guardada():
		GlobalData.cargar_partida()
		get_tree().change_scene_to_file("res://escenas/Otras cosas/pantalla_carga.tscn")
	else:
		mostrar_mensaje("No hay partida guardada")

func _on_opciones_pressed():
	mostrar_mensaje("Función no habilitada")

func _on_salir_pressed():
	print("Saliendo del juego...")
	get_tree().quit()

func verificar_partida_guardada():
	if boton_continuar:
		if not GlobalData.tiene_partida_guardada():
			boton_continuar.disabled = true
			boton_continuar.modulate = Color(0.5, 0.5, 0.5, 0.7)
		else:
			boton_continuar.disabled = false
			boton_continuar.modulate = Color.WHITE

func mostrar_mensaje(texto: String):
	var popup = AcceptDialog.new()
	popup.dialog_text = texto
	popup.title = "Aviso"
	add_child(popup)
	popup.popup_centered()
	
