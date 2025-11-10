extends CharacterBody2D
var velocidad: int
var dir: Vector2
var perseguido: bool
var vida: int
var daño : int = 4
var atacando: bool
var tamaño_ray_activo : float
var tamaño_ray_desactivado : float

var animacion_atacando = false
@export var colision_ataque : CollisionShape2D
@export var sprite : AnimatedSprite2D
@export var barra_vida : ProgressBar
@export var timer_1 : Timer
@export var timer_2 : Timer
@export var ataque_timer : Timer
@export var raycast_derecha : RayCast2D
@export var raycast_izquierda : RayCast2D
@export var area : Area2D

func _ready():
	_iniciar_enemigo()
	atacando = false
	perseguido = false

func _iniciar_enemigo():
	velocidad = 60
	vida = 15
	barra_vida.iniciar_vida(vida)
	barra_vida._set_vida(vida)
	tamaño_ray_activo = 200
	tamaño_ray_desactivado = 40
	
func _process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = dir.x * velocidad
	var objetivo_derecha = raycast_derecha.get_collider()
	var objetivo_izquierda = raycast_izquierda.get_collider()
	if raycast_derecha.is_colliding()  and objetivo_derecha.is_in_group("Jugadores"):
		perseguido = false
		voltear_sprite( Vector2.RIGHT)
		var collision_point: Vector2 = raycast_derecha.get_collision_point()
		var origin_point: Vector2 = global_position
		var distancia: float = origin_point.distance_to(collision_point)
		if distancia >= 30:
			dir = Vector2.RIGHT
			if !atacando:
				velocidad = 60
			else:
				velocidad = 40
		elif !atacando:
				atacar(Vector2.RIGHT)
	elif raycast_izquierda.is_colliding()  and objetivo_izquierda.is_in_group("Jugadores"):
		voltear_sprite( Vector2.LEFT)
		perseguido = false
		var collision_point: Vector2 = raycast_izquierda.get_collision_point()
		var origin_point: Vector2 = global_position
		var distancia: float = origin_point.distance_to(collision_point)
		if distancia >= 30:
			dir = Vector2.LEFT
			if !atacando:
				velocidad = 60
			else:
				velocidad = 40
		elif !atacando:
				atacar(Vector2.LEFT)
	else:
		Vigilar()
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
		area.scale.x = 1
		raycast_derecha.target_position.x = tamaño_ray_activo
		raycast_izquierda.target_position.x = -tamaño_ray_desactivado
	if dir.x == -1:
		sprite.flip_h = true
		area.scale.x = -1
		raycast_izquierda.target_position.x = -tamaño_ray_activo
		raycast_derecha.target_position.x = tamaño_ray_desactivado
		

func Vigilar():
	velocidad = 25
	perseguido = true
	timer_2.wait_time =  choose([ 8.6, 8.5, 8.3, 8.4, 8.7])
	timer_2.start()
	timer_1.wait_time = 0.1
	timer_1.start()

func _on_timer_timeout():
	if perseguido:
		timer_1.wait_time = choose([ 8.6, 8.5, 8.3, 8.4, 8.7])
		dir = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.RIGHT, Vector2.LEFT])
	else:
		timer_1.stop()
		dir = Vector2.ZERO

func choose(array):
	array.shuffle()
	return array.front()

func recibir_daño(daño):
	vida -= daño
	if vida <= 0:
		queue_free()
	barra_vida._set_vida(vida)

func _on_timer_2_timeout() -> void:
	timer_2.stop()

func atacar(direccion: Vector2):
	animacion_atacando = true
	atacando = true
	sprite.play("Ataque_1")
	var espera = 0.3
	await get_tree().create_timer(.2).timeout
	colision_ataque.disabled = false
	await get_tree().create_timer(espera).timeout
	colision_ataque.disabled = true
	ataque_timer.start()
	animacion_atacando = false

func _on_ataque_timeout() -> void:
	atacando = false
	ataque_timer.stop()
	ataque_timer.wait_time = choose([ 5.0, 4.8, 4.4, 3.8, 4.0, 5.2, 4.2])


func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugadores"): 
		body.recibir_daño(daño) 
