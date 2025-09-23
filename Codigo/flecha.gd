extends CharacterBody2D

@export var tiempo_de_vida = 9.0 
const GRAVEDAD = 60.0
var tiempo_actual = 0.0
func _physics_process(delta):
	velocity.y += GRAVEDAD * delta  # caída
	move_and_slide()

	# Rotar flecha según dirección de movimiento
	if velocity.length() > 0.1:
		rotation = velocity.angle()
	if is_on_floor():
		velocity.x = 0 
	# Eliminar flecha si se sale mucho de pantalla
	tiempo_actual += delta
	if tiempo_actual >= tiempo_de_vida:
		queue_free()
