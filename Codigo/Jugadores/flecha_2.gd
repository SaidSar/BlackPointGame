extends CharacterBody2D
@onready var zona_daño = $"ZonaDaño"
var puede_atacar = true
var daño : float = 1
var direccion : Vector2 = Vector2.RIGHT
var velocidad: float = 300
var p0 : Vector2
var p1 : Vector2
var p2 : Vector2
var t : float = 0.0
var vector_apuntando : Vector2 = Vector2.RIGHT

func _physics_process(delta):
	if is_on_floor():
		puede_atacar = false
		daño_area()
	if t < 3.0:
		t += 1.75 * delta
		daño -= (delta + .01)
		
		if t > 3:
			daño_area()
	if puede_atacar:
		position = _quadratic_bezier()

func set_direction(direccion_giro, frame, poder):
	$Sprite2D.frame = frame
	var angle
	var length = max(poder * 300, 30)
	if direccion_giro == false:
		direccion = Vector2.RIGHT
		angle = -5
	else:
		direccion = Vector2.LEFT
		angle = -175
		length = -abs(length)
		$Sprite2D2.flip_h = true
	
	p0 = position
	p2 = position + Vector2(length,16)
	var tilted_unit_vector = (p2-p0).normalized().rotated(deg_to_rad(angle))
	p1 = p0 + length * tilted_unit_vector

func _quadratic_bezier() -> Vector2:
	var time = min(t,1)
	var q0 : Vector2 = p0.lerp(p1,time)
	var q1: Vector2 = p1.lerp(p2,time)
	vector_apuntando = q1-q0
	return p0.lerp(q1,time)

func _on_zona_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos") || body.is_in_group("Entorno"): 
		if body.has_method("recibir_daño"):
			body.recibir_daño(daño) 

func daño_area():
	$Sprite2D2.visible = false
	$Sprite2D.visible = true
	var area_daño = $"area_daño"
	$Sprite2D.play("explosion")
	var colision_zona = area_daño.get_node("CollisionShape2D")
	await get_tree().create_timer(0.1).timeout
	colision_zona.disabled = false
	await get_tree().create_timer(0.3).timeout
	colision_zona.disabled = true
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos") || body.is_in_group("Entorno"): 
		puede_atacar = false
		velocity = Vector2.ZERO
		daño_area()
