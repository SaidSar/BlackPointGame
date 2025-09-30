extends CharacterBody2D
var velocidad: int
var dir: Vector2
var perseguido: bool
var vida: int

func _ready():
	perseguido = false
	velocidad = 20
	vida = 12

func _process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	move(delta)

func move(delta):
	if perseguido:
		velocity += dir * velocidad * delta
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([ 2.5, 2.0, 3.0,])
	if perseguido:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
	pass
	

func choose(array):
	array.shuffle()
	return array.front()

func recibir_daño(daño):
	perseguido = true
	vida -= daño
	if vida <= 0:
		queue_free()
	print("daño recibido: ", daño)
