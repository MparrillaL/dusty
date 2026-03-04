extends Node2D
@export var area_2d: Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.body_entered.connect(_recogida)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _recogida(body):
	if body.is_in_group("dusty"):
		body.sumar_moneda()
		queue_free()
