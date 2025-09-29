extends CharacterBody2D
const SPEED = 150.0
const JUMP_VELOCITY = -300.0
var tipo_ataque: String 
var ataque_actual: bool
var en_aire: bool

@onready var sprite:AnimatedSprite2D = $Sprite
@onready var tiempo_ataque_1 = $Ataque_1
@onready var tiempo_ataque_2 = $Ataque_2
@onready var area_daño = $"Area_daño"

func _ready():
	ataque_actual = false

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
		return
	else:
		tipo_ataque = "Ataque_1"

func Controlador_colisiones_ataques():
	var colision_zona = area_daño.get_node("CollisionShape2D")
	var espera:float
	if tipo_ataque == "Ataque_1":
		espera = 0.5
	if tipo_ataque == "Ataque_2":
		espera = 0.4
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

func _on_sprite_animation_finished() -> void:
	ataque_actual = false
	controlador_ataques()


func _on_ataque_1_timeout() -> void:
	tiempo_ataque_1.stop()


func _on_ataque_2_timeout() -> void:
	tiempo_ataque_2.stop()
