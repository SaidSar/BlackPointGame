extends CharacterBody2D
var velocidad: int
var dir: Vector2
var perseguido: bool
var vida: int
var daño = 2
var atacando: bool

@export var shader_daño : ShaderMaterial
@export var barra_vida : ProgressBar
@export var timer_1 : Timer
@export var timer_2 : Timer
@export var ataque_timer : Timer
@export var raycast_derecha : RayCast2D
@export var raycast_izquierda : RayCast2D
@export var sprite : AnimatedSprite2D
@onready var flecha_escena = preload("res://escenas//Enemigos//flecha_enemigo.tscn")

var tiempo_carga: float = 0.4
const CARGA_MAX = 1.5 
const FUERZA_MAX = 1200.0  
const FUERZA_MIN = 400.0   

func _ready():
	atacando = false
	perseguido = false
	velocidad = 50
	vida = 15
	barra_vida.iniciar_vida(vida)
	barra_vida._set_vida(vida)

func _process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = dir.x * velocidad
	if !perseguido:
		if raycast_derecha.is_colliding() and !atacando:
			var objetivo = raycast_derecha.get_collider()
			if objetivo and objetivo.is_in_group("Jugadores"):
				atacar(Vector2.RIGHT)
		if raycast_izquierda.is_colliding() and !atacando:
			var objetivo = raycast_izquierda.get_collider()
			if objetivo and objetivo.is_in_group("Jugadores"):
				atacar(Vector2.LEFT)
	move_and_slide()

#func Controlador_animaciones(dir):
	#if !atacando:
		#if is_on_floor():
			#if !velocity:
				#sprite.play("Parado")
			#if velocity:
				#sprite.play("Corriendo")
				#voltear_sprite(dir)
		#else: 
			#sprite.play("Callendo")

func _on_timer_timeout():
	if timer_2.is_stopped():
			perseguido = false
	if perseguido:
		timer_1.wait_time = choose([ 2.6, 2.5, 2.3, 2.4, 1.7])
		dir = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.RIGHT, Vector2.LEFT])
	else:
		timer_1.stop()
		dir = Vector2.ZERO

func choose(array):
	array.shuffle()
	return array.front()

func recibir_daño(daño):
	perseguido = true
	timer_2.wait_time = choose([ 4.0, 3.8, 4.2, 4.6])
	timer_2.start()
	timer_1.wait_time = 0.1
	timer_1.start()
	vida -= daño
	if vida <= 0:
		queue_free()
	#sprite.material = shader_daño
	await get_tree().create_timer(.2).timeout
	sprite.material = null
	barra_vida._set_vida(vida)
	

func _on_timer_2_timeout() -> void:
	timer_2.stop()

func atacar(direccion: Vector2):
	atacando = true
	if flecha_escena == null:
		return
	var flecha = flecha_escena.instantiate()
	get_parent().add_child(flecha)
	flecha.global_position = global_position
	var factor_carga = tiempo_carga / CARGA_MAX
	var fuerza = lerp(FUERZA_MIN, FUERZA_MAX, factor_carga)
	var direccion_flecha = Vector2(1.5, 0)
	if direccion == Vector2.LEFT:
		direccion_flecha.x = -1
	flecha.velocity = direccion_flecha * fuerza
	ataque_timer.start()

func _on_ataque_timeout() -> void:
	atacando = false
	ataque_timer.stop()
	ataque_timer.wait_time = choose([ 5.0, 4.8, 4.4, 3.8, 4.0, 5.2, 4.2])
