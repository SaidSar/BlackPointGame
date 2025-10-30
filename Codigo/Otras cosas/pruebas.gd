extends Node2D
@onready var h = $CanvasLayer
func _ready() -> void:
	await get_tree().process_frame
	h.visible = true
	$Mago.set_hud(h)
