extends CharacterBody2D
var velocidad : float = 60
var dir := Vector2.ZERO
var guardia :bool = false
var vida :int = 22
var daño := 4
var atacando :bool = false
var animacion_atacando :bool = false
var tamaño_ray_activo : float = 200
var tamaño_ray_desactivado : float = 40

@export var shader_daño : ShaderMaterial
@export var colision_ataque : CollisionShape2D
@export var sprite : AnimatedSprite2D
@export var barra_vida : ProgressBar
@export var timer_1 : Timer
@export var timer_2 : Timer
@export var ataque_timer : Timer
@export var raycast_derecha : RayCast2D
@export var raycast_izquierda : RayCast2D
@export var raycast_suelo_der : RayCast2D
@export var raycast_suelo_izq : RayCast2D
@export var area : Area2D

func _ready():
	atacando = false
	guardia = false
	barra_vida.iniciar_vida(vida)
	barra_vida._set_vida(vida)

func _process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if _va_a_caer():
		dir = Vector2.ZERO
		velocidad = 0
		Vigilar()
		move_and_slide()
		return
	velocity.x = dir.x * velocidad
	_detectar_jugador()
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
			
func _va_a_caer() -> bool:
	if dir.x > 0: 
		return not raycast_suelo_der.is_colliding()
	elif dir.x < 0: 
		return not raycast_suelo_izq.is_colliding()
	return false

func _detectar_jugador():
	var objetivo_derecha = raycast_derecha.get_collider()
	var objetivo_izquierda = raycast_izquierda.get_collider()

	# MIRANDO DERECHA
	if raycast_derecha.is_colliding() and objetivo_derecha.is_in_group("Jugadores"):
		_guardar_logica_det( Vector2.RIGHT, raycast_derecha )

	# MIRANDO IZQUIERDA
	elif raycast_izquierda.is_colliding() and objetivo_izquierda.is_in_group("Jugadores"):
		_guardar_logica_det( Vector2.LEFT, raycast_izquierda )

	else:
		Vigilar()


func _guardar_logica_det(direccion: Vector2, raycast: RayCast2D):
	guardia = false
	voltear_sprite(direccion)
	var distancia := global_position.distance_to(raycast.get_collision_point())
	if distancia >= 30:
		dir = direccion
		if atacando:
			velocidad =  40
		else: 
			velocidad =  60
	elif not atacando:
		atacar(direccion)
	
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
	guardia = true
	timer_2.wait_time =  choose([ 8.6, 8.5, 8.3, 8.4, 8.7])
	timer_2.start()
	timer_1.wait_time = 0.1
	timer_1.start()

func _on_timer_timeout():
	if guardia:
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
	sprite.material = shader_daño
	await get_tree().create_timer(.2).timeout
	sprite.material = null
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
	if body.is_in_group("Jugadores") || body.is_in_group("Entorno"): 
		body.recibir_daño(daño) 
