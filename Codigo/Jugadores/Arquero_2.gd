extends CharacterBody2D
@export var sprite :AnimatedSprite2D
@export var hud : CanvasLayer
@export var shader_daño : ShaderMaterial
@onready var flecha_escena = preload("res://escenas//Proyectiles//flecha.tscn")
@onready var flecha_escena_2 = preload("res://escenas//Proyectiles//flecha_explosiva.tscn")
@export var tiempo_ataque_1 : Timer
@export var tiempo_ataque_2 : Timer
@export var carga : ProgressBar
@onready var barra_vida
@onready var icono_1
@onready var icono_2

var daño: float = 5
var tiempo_carga: float = 0
const carga_max = 1.1 

var tipo_ataque: String 
var ataque_actual: bool
var en_aire: bool
var doble_salto: bool
var vida_maxima : float
var vida : float
const salto = -270.0
var velocidad : float = 100
var puede_moverse : bool = true:
	set(value):
		puede_moverse = value
		if value == false:
			velocidad = 0
		else:
			velocidad = 100

func _ready():
	vida_maxima = 35
	vida = vida_maxima
	tiempo_ataque_1.stop()
	tiempo_ataque_2.stop()
	set_hud()

func set_hud():
	barra_vida = hud.get_node("BarraVida")
	icono_1 = hud.get_node("Ataque_1_Icono/Barra")
	icono_2 = hud.get_node("Ataque_2_Icono/Barra")
	barra_vida.iniciar_vida(vida)
	barra_vida._set_vida(vida)
	icono_1.min_value = 0
	icono_1.max_value = tiempo_ataque_1.wait_time
	icono_1.value = 0
	tiempo_ataque_1.connect("timeout", Callable(self, "_on_tiempo_ataque_1_timeout"))
	icono_1.step = .05
	icono_2.min_value = 0
	icono_2.max_value = tiempo_ataque_2.wait_time
	icono_2.value = 0
	tiempo_ataque_2.connect("timeout", Callable(self, "_on_tiempo_ataque_2_timeout"))
	icono_2.step = .05
	carga.visible = false
	hud.visible = true

func _physics_process(delta: float) -> void:
	if ataque_actual:
		if tiempo_carga < carga_max:
			tiempo_carga += delta
			carga.value = tiempo_carga
	
	if tiempo_ataque_1.time_left > 0:
		icono_1.value = tiempo_ataque_1.time_left
	if tiempo_ataque_2.time_left > 0:
		icono_2.value = tiempo_ataque_2.time_left
	if not is_on_floor():
		velocity += get_gravity() * delta
		en_aire = true
	else: 
		en_aire = false
		doble_salto = true
	if Input.is_action_just_pressed("Espacio") || Input.is_action_just_pressed("control_salto"):
		if en_aire:
			if doble_salto:
				velocity.y = salto
				doble_salto = false
		else:
			velocity.y = salto
	var direction = Input.get_axis("A", "D") + Input.get_axis("stick_izquierda", "stick_derecha")
	if direction and !ataque_actual and puede_moverse:
		velocity.x = direction * velocidad
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)
	move_and_slide()
	Controlador_animaciones(direction)

func _input(event: InputEvent):
	if event.is_action_pressed("click_izquierdo") and tiempo_ataque_1.is_stopped() and !ataque_actual:
		ataque_actual = true
		carga.value = 0
		carga.visible = true
		sprite.play("Ataque_1")
	if event.is_action_released("click_izquierdo")  and ataque_actual:
		ataque_actual = false
		carga.visible = false
		if tiempo_carga >= .35:
			tiempo_ataque_1.start()
			disparar_flecha(tiempo_carga)
		tiempo_carga = 0
		
	if event.is_action_pressed("click_derecho") and tiempo_ataque_2.is_stopped() and !ataque_actual:
		ataque_actual = true
		carga.value = 0
		carga.visible = true
		sprite.play("Ataque_2")
	if event.is_action_released("click_derecho")  and ataque_actual:
		ataque_actual = false
		carga.visible = false
		if tiempo_carga >= .35:
			tiempo_ataque_2.start()
			disparar_flecha_2(tiempo_carga)
		tiempo_carga = 0

func disparar_flecha(tiempo_carga):
	var flecha = flecha_escena.instantiate()
	flecha.position = position
	flecha.set_direction(sprite.flip_h, 0, tiempo_carga)
	flecha.daño = daño * tiempo_carga
	get_parent().add_child(flecha)

func disparar_flecha_2(tiempo_carga):
	var flecha = flecha_escena_2.instantiate()
	flecha.position = position
	flecha.set_direction(sprite.flip_h, 0, tiempo_carga)
	flecha.daño = daño * tiempo_carga
	get_parent().add_child(flecha)
	
func Controlador_animaciones(dir):
	if !ataque_actual:
		if is_on_floor():
			if !velocity:
				sprite.play("Parado")
			if velocity:
				sprite.play("Corriendo")
				voltear_sprite(dir)
		else: 
			sprite.play("Callendo")

func voltear_sprite(dir):
	if dir == 1:
		sprite.flip_h = false
	if dir == -1:
		sprite.flip_h = true

func _on_ataque_1_timeout():
	tiempo_ataque_1.stop()

func _on_ataque_2_timeout():
	tiempo_ataque_2.stop()

func recibir_daño(daño_recibido):
	vida -= daño_recibido
	if vida <= 0:
		queue_free()
	sprite.material = shader_daño
	await get_tree().create_timer(.2).timeout
	sprite.material = null
	barra_vida._set_vida(vida)
