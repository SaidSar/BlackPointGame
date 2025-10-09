extends CharacterBody2D
const SPEED = 150.0
const JUMP_VELOCITY = -250.0
var tipo_ataque: String 
var ataque_actual: bool
var en_aire: bool
var daño: int
var vida: int

@onready var barra_vida = $"Camera2D/BarraVida"
@onready var sprite:AnimatedSprite2D = $Sprite
@onready var tiempo_ataque_1 = $Ataque_1
@onready var tiempo_ataque_2 = $Ataque_2
@onready var area_daño = $"Area_daño"
@onready var especial_escena = preload("res://escenas//Proyectiles//melee_especial.tscn")

func _ready():
	vida = 100
	ataque_actual = false
	barra_vida.iniciar_vida(vida)
	barra_vida._set_vida(vida)

func Controlador_animaciones_ataques():
	if tipo_ataque != "":
		sprite.play(str(tipo_ataque))
		ataque_actual = true
		Controlador_colisiones_ataques()

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		en_aire = true
	else: 
		en_aire = false
	if Input.is_action_just_pressed("Espacio") and !en_aire:
		velocity.y = JUMP_VELOCITY
	var direction = Input.get_axis("A", "D")
	if direction and !ataque_actual :
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if ataque_actual == false and !en_aire:
		if Input.is_action_just_pressed("click_izquierdo") and tiempo_ataque_1.is_stopped():
			daño = 3
			tipo_ataque = "Ataque_1"
			tiempo_ataque_1.start()
			ataque_actual = true
		elif Input.is_action_pressed("click_derecho") and tiempo_ataque_2.is_stopped():
			tipo_ataque = "Ataque_2"
			tiempo_ataque_2.start()
			ataque_actual = true
		elif Input.is_action_just_pressed("shift"):
			tipo_ataque = "Ataque_3"
			ataque_actual = true
		else:
			tipo_ataque = ""
		Controlador_animaciones_ataques()
	move_and_slide()
	Controlador_animaciones(direction)

func controlador_ataques():
	if tipo_ataque == "Ataque_1":
		return
	if tipo_ataque == "Ataque_2":
		ataque_especial()
		return
	else:
		tipo_ataque = "Ataque_1"

func Controlador_colisiones_ataques():
	var colision_zona = area_daño.get_node("CollisionShape2D")
	var espera:float
	if tipo_ataque == "Ataque_1":
		espera = 0.5
	if tipo_ataque == "Ataque_3":
		espera = 0.3
	colision_zona.disabled = false
	await get_tree().create_timer(espera).timeout
	colision_zona.disabled = true

func voltear_sprite(dir):
	if dir == 1:
		sprite.flip_h = false
		area_daño.scale.x = 1
	if dir == -1:
		sprite.flip_h = true
		area_daño.scale.x = -1

func Controlador_animaciones(dir):
	if !ataque_actual:
		if is_on_floor():
			if  velocity.length() == 0:
				sprite.play("Parado")
			if velocity:
				sprite.play("Corriendo")
				voltear_sprite(dir)
		else: 
			sprite.play("Callendo")


func ataque_especial():
	if especial_escena == null:
		return
	var especial = especial_escena.instantiate()
	get_parent().add_child(especial)
	especial.global_position = global_position
	var factor_carga = 0.2 / 1.5 
	var fuerza = lerp(400.0, 1200.0, factor_carga)
	var direccion = Vector2(1, 0)
	if sprite.flip_h:
		direccion.x = -1
	especial.velocity = direccion.normalized()  * fuerza

func _on_sprite_animation_finished() -> void:
	ataque_actual = false
	controlador_ataques()


func _on_ataque_1_timeout() -> void:
	tiempo_ataque_1.stop()


func _on_ataque_2_timeout() -> void:
	tiempo_ataque_2.stop()


func _on_area_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos"): 
		if body.has_method("recibir_daño"):
			body.recibir_daño(daño) 

func recibir_daño(daño_recibido):
	vida -= daño_recibido
	if vida <= 0:
		queue_free()
	barra_vida._set_vida(vida)
	print("daño recibido jugador: ", daño_recibido)
