extends StaticBody2D
@onready var vida: float = 2
func recibir_daño(daño):
	vida -= daño
	if vida <= 0:
		daño_area()

func daño_area():
	var area_daño = $"area_daño"
	$Sprite2D.play("explosion")
	var colision_zona = area_daño.get_node("CollisionShape2D")
	await get_tree().create_timer(0.1).timeout
	colision_zona.disabled = false
	await get_tree().create_timer(0.4).timeout
	colision_zona.disabled = true
	queue_free()
