extends ProgressBar

@onready var timer = $Timer
@onready var barra_daño = $"Barra_daño"
var vida = 0 : set = _set_vida

func _set_vida(nueva_vida):
	var prev_vida = vida
	vida = min(max_value, nueva_vida)
	value = vida
	if vida <=0:
		queue_free()
	if vida < prev_vida:
		timer.start()
	else:
		barra_daño.value = vida

func iniciar_vida(vida):
	max_value = vida
	barra_daño.max_value = vida
	barra_daño.value = vida


func _on_timer_timeout() -> void:
	barra_daño.value = vida
