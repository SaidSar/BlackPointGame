# seleccion_personaje.gd
extends Control

# Referencias a los botones
@onready var boton_arquero = $BotonArquero
@onready var boton_mago = $BotonMago
@onready var boton_guerrero = $BotonGuerrero
@onready var boton_iniciar_juego = $BotonIniciarJuego

# Variable para saber qué personaje está seleccionado
var personaje_seleccionado: String = ""

func _ready():
	# Conectar las señales de los botones de personajes
	boton_arquero.pressed.connect(func(): seleccionar_personaje("arquero", boton_arquero))
	boton_mago.pressed.connect(func(): seleccionar_personaje("mago", boton_mago))
	boton_guerrero.pressed.connect(func(): seleccionar_personaje("guerrero", boton_guerrero))
	
	# Conectar el botón de iniciar juego
	boton_iniciar_juego.pressed.connect(_on_iniciar_juego_pressed)
	
	# Desactivar el botón de iniciar al principio
	boton_iniciar_juego.disabled = true

func seleccionar_personaje(nombre_personaje: String, boton_presionado: Button):
	# Guardar el personaje seleccionado
	personaje_seleccionado = nombre_personaje
	
	# Guardar en GlobalData
	GlobalData.personaje_seleccionado = nombre_personaje
	
	# Resetear color de todos los botones a blanco
	boton_arquero.modulate = Color.WHITE
	boton_mago.modulate = Color.WHITE
	boton_guerrero.modulate = Color.WHITE
	
	# Resaltar el botón seleccionado en dorado
	boton_presionado.modulate = Color.GOLD
	
	# Activar el botón de iniciar juego
	boton_iniciar_juego.disabled = false
	
	print("Personaje seleccionado: ", nombre_personaje)

func _on_iniciar_juego_pressed():
	# Reiniciar progreso del juego (empieza desde nivel 1)
	GlobalData.reiniciar_progreso()
	
	print("Iniciando juego con: ", GlobalData.personaje_seleccionado)
	
	# Ir a la pantalla de carga
	get_tree().change_scene_to_file("res://escenas/Otras cosas/pantalla_carga.tscn")
