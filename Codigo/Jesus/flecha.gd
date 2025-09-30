extends CharacterBody2D
@onready var zona_daño = $"ZonaDaño"
@export var tiempo_de_vida = 7.0 
const GRAVEDAD = 50.0
var tiempo_actual = 0.0
var puede_atacar = true
var daño = 5

func _physics_process(delta):
	if is_on_floor():
		velocity = Vector2.ZERO
		puede_atacar = false
	else:
		velocity.y += GRAVEDAD * delta  # caída
		move_and_slide()
		if velocity.length() > 0.1:
			rotation = velocity.angle()
	
	tiempo_actual += delta
	if tiempo_actual >= tiempo_de_vida:
		queue_free()


func _on_zona_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos") and puede_atacar: 
		if body.has_method("recibir_daño"):
			body.recibir_daño(daño) 
			queue_free()
