extends CharacterBody2D
const SPEED = 100.0
const JUMP_VELOCITY = -275.0
var tipo_ataque: String 
var ataque_actual: bool
var en_aire: bool
var daño = 5
var vida:float
var vida_maxima:float
var reseteo_escudo : float
var escudo_tiempo: float

@onready var area_daño = $"Area_daño"
@onready var area = $"Area"
@onready var sprite = $Sprite
@onready var tiempo_ataque_1 = $Ataque_1
@onready var tiempo_ataque_2 = $Ataque_2
@onready var tiempo_ataque_3 = $Ataque_3
@onready var barra_vida 
@onready var especial_escena = preload("res://escenas//Proyectiles//Mago_proyectil.tscn")
@onready var colision_ataque_1 
@onready var colision_ataque_3
@onready var sprite_ataque_1

@onready var camara 
@onready var icono_1 
@onready var icono_2  
@onready var icono_3
@onready var hud = $CanvasLayer

func _ready():
	vida_maxima = 50
	vida = vida_maxima
	ataque_actual = false
	reseteo_escudo = 15.0
	escudo_tiempo = 30.0
	
	sprite_ataque_1 = area_daño.get_node("Sprite2D")
	sprite_ataque_1.visible = false
	colision_ataque_3 = area.get_node("CollisionShape2D")
	colision_ataque_1 = area_daño.get_node("CollisionShape2D")
	set_hud()

func set_hud():
	barra_vida = hud.get_node("BarraVida")
	icono_1 = hud.get_node("Ataque_1_Icono/Barra")
	icono_2 = hud.get_node("Ataque_2_Icono/Barra")
	icono_3 = hud.get_node("Ataque_3_Icono/Barra")
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
	
	icono_3.min_value = 0
	icono_3.max_value = tiempo_ataque_3.wait_time
	icono_3.value = 0
	tiempo_ataque_3.connect("timeout", Callable(self, "_on_tiempo_ataque_3_timeout"))
	icono_3.step = .05
	
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
	if tiempo_ataque_3.time_left > 0:
		icono_3.value = tiempo_ataque_3.time_left

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
		elif Input.is_action_just_pressed("shift") and tiempo_ataque_3.is_stopped():
			tipo_ataque = "Ataque_3"
			tiempo_ataque_3.wait_time = escudo_tiempo
			ataque_actual = true
		else:
			tipo_ataque = ""
		Controlador_animaciones_ataques(tipo_ataque)
	move_and_slide()
	Controlador_animaciones(direction)

func controlador_ataques():
	var espera:float
	if tipo_ataque == "Ataque_1":
		espera = 0.2
		await get_tree().create_timer(.15).timeout
		sprite_ataque_1.visible = true
		colision_ataque_1.disabled = false
		await get_tree().create_timer(espera).timeout
		colision_ataque_1.disabled = true
		sprite_ataque_1.visible = false
		
	if tipo_ataque == "Ataque_2":
		await get_tree().create_timer(.2).timeout
		ataque_especial()
		
	if tipo_ataque == "Ataque_3":
		espera = 0.6
		colision_ataque_3.disabled = false
		await get_tree().create_timer(espera).timeout
		colision_ataque_3.disabled = true
		tiempo_ataque_3.start()
		ataque_actual = false
		
	else: 
		return



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
			if !velocity:
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



func _on_area_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos"): 
		if body.has_method("recibir_daño"):
			body.recibir_daño(daño) 


func _on_sprite_animation_changed() -> void:
	controlador_ataques()


func _on_sprite_animation_finished() -> void:
	ataque_actual = false


func recibir_daño(daño_recibido):
	if colision_ataque_3.disabled == false:
		colision_ataque_3.disabled = true
		sprite.play("Parado")
		tipo_ataque = ""
		tiempo_ataque_3.wait_time = reseteo_escudo
		
	else:
		vida -= daño_recibido
		if vida <= 0:
			queue_free()
		barra_vida._set_vida(vida)
		print("daño recibido jugador: ", daño_recibido)

func _on_ataque_1_timeout():
	tiempo_ataque_1.stop()

func _on_ataque_2_timeout():
	tiempo_ataque_2.stop()

func _on_ataque_3_timeout() -> void:
	tiempo_ataque_3.stop()
