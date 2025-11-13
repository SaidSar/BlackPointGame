extends CharacterBody2D
@onready var zona_daño = $"ZonaDaño"
@export var tiempo_de_vida = 0.35
const velocidad = 3.5
var tiempo_actual: float
var daño: int
func _ready():
	daño = 5
	tiempo_actual = 0.0

func _physics_process(delta):
	velocity.x += velocidad * delta  
	move_and_slide()
	if velocity.length() > 0.1:
		rotation = velocity.angle()
	
	tiempo_actual += delta
	if tiempo_actual >= tiempo_de_vida:
		queue_free()

func _on_zona_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos") || body.is_in_group("Entorno"): 
		if body.has_method("recibir_daño"):
			body.recibir_daño(daño) 
