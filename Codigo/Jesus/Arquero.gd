extends CharacterBody2D
const SPEED = 150.0
const JUMP_VELOCITY = -300.0
var tipo_ataque: String 
var ataque_actual: bool
var en_aire: bool
var doble_salto: bool

@onready var zona_daño = $"AreadeDaño"
@onready var sprite = $Sprite
@onready var tiempo_ataque_1 = $Ataque_1
@onready var tiempo_ataque_2 = $Ataque_2
@onready var flecha_escena = preload("res://escenas//jesus//flecha.tscn")
@onready var flecha_escena_2 = preload("res://escenas//jesus//flecha_2.tscn")

#cosas para la flechas
var cargando_flecha: bool = false
var tiempo_carga: float = 0.2
const CARGA_MAX = 1.5 
const FUERZA_MAX = 1200.0  
const FUERZA_MIN = 400.0   

func _ready():
	ataque_actual = false

func Controlador_animaciones_ataques(ataque):
	if tipo_ataque != "":
		sprite.play(str(ataque))
		ataque_actual = true

func _physics_process(delta):
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
	var direccion = Vector2(1, 0)
	if sprite.flip_h:
		direccion.x = -1
	flecha.velocity = direccion * fuerza

func disparar_flecha_2():
	var flecha = flecha_escena_2.instantiate()
	get_parent().add_child(flecha)
	flecha.global_position = global_position
	var factor_carga = tiempo_carga / (CARGA_MAX + 100 )
	var fuerza = lerp(FUERZA_MIN, FUERZA_MAX, factor_carga)
	var angulo = deg_to_rad(20)
	var direccion = Vector2(cos(angulo), -sin(angulo))
	if sprite.flip_h:
		direccion.x = -1
	flecha.velocity =  direccion.normalized()  * fuerza

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
