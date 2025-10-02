extends CharacterBody2D
var velocidad: int
var dir: Vector2
var perseguido: bool
var vida: int
var daño = 2
@onready var barra_vida = $BarraVida
@onready var timer_1 = $Timer
@onready var timer_2 = $Timer2

func _ready():
	perseguido = false
	velocidad = 50
	vida = 15
	barra_vida.iniciar_vida(vida)
	barra_vida._set_vida(vida)

func _process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = dir.x * velocidad
	move_and_slide()

func _on_timer_timeout():
	if perseguido:
		timer_1.wait_time = choose([ 2.6, 2.5, 2.3, 2.4, 1.7])
		dir = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.RIGHT, Vector2.LEFT])
	else:
		timer_1.stop()
		dir = Vector2.ZERO



func choose(array):
	array.shuffle()
	return array.front()

func recibir_daño(daño):
	perseguido = true
	timer_2.wait_time = choose([ 4.0, 3.8, 4.2, 4.6])
	timer_2.start()
	timer_1.wait_time = 0.1
	timer_1.start()
	
	vida -= daño
	if vida <= 0:
		queue_free()
	barra_vida._set_vida(vida)
	print("daño recibido: ", daño)

func _on_timer_2_timeout() -> void:
	perseguido = false
	timer_2.stop()

func atacar():
	pass
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugadores"): 
		atacar()
