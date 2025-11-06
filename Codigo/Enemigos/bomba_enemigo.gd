extends CharacterBody2D
@onready var area_daño = $"area_daño"
@export var tiempo_de_vida = 3.0
var GRAVEDAD = 450.0
var tiempo_actual = 0.0
var daño = 5

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
		daño_area()

func _on_zona_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugadores"): 
		body.recibir_daño(daño) 
	if body.is_in_group("Enemigos"): 
		body.recibir_daño(daño) 

func daño_area():
	$Sprite2D.play("Explosion")
	var colision_zona = area_daño.get_node("CollisionShape2D")
	await get_tree().create_timer(0.01).timeout
	colision_zona.disabled = false
	await get_tree().create_timer(0.2).timeout
	colision_zona.disabled = true
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugadores") || body.is_in_group("Enemigos") : 
		GRAVEDAD = 0.0
		velocity = Vector2.ZERO
		daño_area()
