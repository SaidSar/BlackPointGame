extends CharacterBody2D
const SPEED = 120.0
const JUMP_VELOCITY = -270.0
var tipo_ataque: String 
var ataque_actual: bool
var en_aire: bool
var doble_salto: bool
var vida_maxima : float
var vida : float


@export var sprite :AnimatedSprite2D
@export var tiempo_ataque_1 : Timer
@export var tiempo_ataque_2 : Timer
@export var hud : CanvasLayer
@onready var flecha_escena = preload("res://escenas//Proyectiles//flecha.tscn")
@onready var flecha_escena_2 = preload("res://escenas//Proyectiles//flecha_2.tscn")
@onready var barra_vida
@onready var icono_1
@onready var icono_2

#cosas para la flechas
var cargando_flecha: bool = false
var tiempo_carga: float = 0.2
const CARGA_MAX = 1.5 
const FUERZA_MAX = 1200.0  
const FUERZA_MIN = 400.0   

func _ready():
	ataque_actual = false
	vida_maxima = 60
	vida = vida_maxima
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
	
	hud.visible = true

func Controlador_animaciones_ataques(ataque):
	if tipo_ataque != "":
		sprite.play(str(ataque))
		ataque_actual = true

func _physics_process(delta):
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
	if Input.is_action_just_pressed("Espacio"):
		if en_aire:
			if doble_salto:
				velocity.y = JUMP_VELOCITY
				doble_salto = false
		else:
			velocity.y = JUMP_VELOCITY
		
	var direction = Input.get_axis("A", "D")
	if direction and !ataque_actual :
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if ataque_actual == false and !en_aire:
		if Input.is_action_just_pressed("click_izquierdo") and tiempo_ataque_1.is_stopped():
			cargando_flecha = true
			tiempo_carga = min(tiempo_carga + delta, CARGA_MAX)
			tipo_ataque = "Ataque_1"
			tiempo_ataque_1.start()
			ataque_actual = true
		elif Input.is_action_pressed("click_derecho") and tiempo_ataque_2.is_stopped():
			cargando_flecha = true
			tiempo_carga = min(tiempo_carga + delta, CARGA_MAX)
			tipo_ataque = "Ataque_2"
			tiempo_ataque_2.start()
			ataque_actual = true
		elif Input.is_action_just_pressed("shift"):
			tipo_ataque = "Ataque_3"
			ataque_actual = true
		else:
			tipo_ataque = ""
		Controlador_animaciones_ataques(tipo_ataque)
	move_and_slide()
	Controlador_animaciones(direction)

func controlador_ataques():
	if tipo_ataque == "Ataque_1":
		disparar_flecha()
	if tipo_ataque == "Ataque_2":
		disparar_flecha_2()
	else:
		return
	tipo_ataque = ""
	pass

func disparar_flecha():
	if flecha_escena == null:
		return
	var flecha = flecha_escena.instantiate()
	get_parent().add_child(flecha)
	flecha.global_position = global_position
	var factor_carga = tiempo_carga / CARGA_MAX
	var fuerza = lerp(FUERZA_MIN, FUERZA_MAX, factor_carga)
	var direccion_flecha = Vector2(1, 0)
	if sprite.flip_h:
		direccion_flecha.x = -1
	flecha.velocity = direccion_flecha * fuerza

func disparar_flecha_2():
	var flecha = flecha_escena_2.instantiate()
	get_parent().add_child(flecha)
	flecha.global_position = global_position
	var factor_carga = tiempo_carga / (CARGA_MAX + 100 )
	var fuerza = lerp(FUERZA_MIN, FUERZA_MAX, factor_carga)
	var angulo = deg_to_rad(20)
	var direccion_flecha = Vector2(cos(angulo), -sin(angulo))
	if sprite.flip_h:
		direccion_flecha.x = -1
	flecha.velocity =  direccion_flecha.normalized()  * fuerza

func voltear_sprite(dir):
	if dir == 1:
		sprite.flip_h = false
	if dir == -1:
		sprite.flip_h = true

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


func _on_sprite_animation_finished():
	ataque_actual = false
	controlador_ataques()

func _on_ataque_1_timeout():
	tiempo_ataque_1.stop()

func _on_ataque_2_timeout():
	tiempo_ataque_2.stop()

func recibir_daño(daño_recibido):
	vida -= daño_recibido
	if vida <= 0:
		queue_free()
	barra_vida._set_vida(vida)
