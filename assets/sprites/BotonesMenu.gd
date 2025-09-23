extends VBoxContainer

func _ready():
	for boton in get_children():
		if boton is Button:
			configurar_glow_boton(boton)

func configurar_glow_boton(boton: Button):
	var color_original = boton.modulate
	
	boton.mouse_entered.connect(func():
		var tween = create_tween()
		# Efecto de brillo dorado
		tween.tween_property(boton, "modulate", Color(1.2, 1.0, 0.3, 1.0), 0.3)
	)
	
	boton.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(boton, "modulate", color_original, 0.3)
	)


func _on_boton_salir_pressed() -> void:
	get_tree().quit()
