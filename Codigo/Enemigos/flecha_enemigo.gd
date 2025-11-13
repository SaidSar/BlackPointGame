extends CharacterBody2D
@onready var zona_daño = $"ZonaDaño"
@export var tiempo_de_vida = 5.0 
var GRAVEDAD = 30.0
var tiempo_actual : float
var puede_atacar: bool
var daño :	int 

func _ready():
	tiempo_actual = 0.0
	puede_atacar = true
	daño = 4

func _physics_process(delta):
	if is_on_floor():
		velocity = Vector2.ZERO
		puede_atacar = false
	else:
		velocity.y += GRAVEDAD * delta
		move_and_slide()
		if velocity.length() > 0.1:
			rotation = velocity.angle()
	tiempo_actual += delta
	if tiempo_actual >= tiempo_de_vida:
		queue_free()


func _on_zona_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugadores") and puede_atacar: 
		GRAVEDAD = 0
		velocity = Vector2.ZERO
		body.recibir_daño(daño)
		queue_free()
