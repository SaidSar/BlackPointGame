extends CharacterBody2D
@export var tiempo_de_vida = 9.0 
const GRAVEDAD = 400.0
var tiempo_actual = 0.0

func _physics_process(delta):
	if is_on_floor():
		velocity = Vector2.ZERO
	else:
		velocity.y += GRAVEDAD * delta
		move_and_slide()
		if velocity.length() > 0.1:
			rotation = velocity.angle()
	
	tiempo_actual += delta
	if tiempo_actual >= tiempo_de_vida:
		queue_free()
