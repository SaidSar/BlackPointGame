extends CharacterBody2D
const speed = 30.0
var dir: Vector2
var perseguido: bool

func _ready():
	perseguido = false

func _process(delta):
	move(delta)

func move(delta):
	if !perseguido:
		velocity += dir * speed * delta
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([1.0, 1.5, 2.0])
	if !perseguido:
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
		
	pass
	

func choose(array):
	array.shuffle()
	return array.front()
