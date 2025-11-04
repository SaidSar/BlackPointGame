extends CharacterBody2D
var velocidad: int
var dir: Vector2
var perseguido: bool
var vida: int
var daño = 2
var atacando: bool
var animacion_atacando: bool
@onready var sprite = $Sprite
@onready var barra_vida = $BarraVida
@onready var timer_1 = $Timer
@onready var timer_2 = $Timer2
@onready var ataque_timer = $Ataque
@onready var raycast_derecha = $Derecha
@onready var raycast_izquierda = $Izquierda
@onready var bomba = preload("res://escenas/Enemigos/bomba_enemigo.tscn")

var tiempo_carga: float = 0.3
const CARGA_MAX = 1.5 
const FUERZA_MAX = 1200.0  
const FUERZA_MIN = 300.0   

func _ready():
	atacando = false
	perseguido = false
	velocidad = 50
	vida = 22
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
				sprite.flip_h = false
				atacar(Vector2.RIGHT)
		if raycast_izquierda.is_colliding() and !atacando:
			var objetivo = raycast_izquierda.get_collider()
			if objetivo and objetivo.is_in_group("Jugadores"):
				sprite.flip_h = true
				atacar(Vector2.LEFT)
	move_and_slide()
	Controlador_animaciones(dir)


func Controlador_animaciones(dir):
	if !animacion_atacando:
		if is_on_floor():
			if !velocity:
				sprite.play("Parado")
			if velocity:
				sprite.play("Corriendo")
				voltear_sprite(dir)
		else: 
			sprite.play("Callendo")
func voltear_sprite(dir):
	if dir.x == 1:
		sprite.flip_h = false
	if dir.x == -1:
		sprite.flip_h = true


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
	barra_vida._set_vida(vida)
	print("daño recibido: ", daño)

func _on_timer_2_timeout() -> void:
	timer_2.stop()

func atacar(direccion: Vector2):
	atacando = true
	ataque_timer.start()
	animacion_atacando = true
	if bomba == null:
		return
	sprite.play("Atacando")
	await get_tree().create_timer(.1).timeout
	var bom = bomba.instantiate()
	get_parent().add_child(bom)
	bom.global_position = global_position
	var factor_carga = tiempo_carga / (CARGA_MAX + 50 )
	var fuerza = lerp(FUERZA_MIN, FUERZA_MAX, factor_carga)
	var angulo = deg_to_rad(30)
	var direccion_bom = Vector2(cos(angulo), -sin(angulo))
	if sprite.flip_h:
		direccion_bom.x = -1
	bom.velocity =  direccion_bom.normalized()  * fuerza
	await get_tree().create_timer(.4).timeout
	animacion_atacando = false

func _on_ataque_timeout() -> void:
	atacando = false
	ataque_timer.stop()
	ataque_timer.wait_time = choose([ 5.0, 4.8, 4.4, 5.8, 5.4, 5.2, 4.6])
