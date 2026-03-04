extends Node2D

@export var area_2d: Area2D

func _ready() -> void:
	area_2d.body_entered.connect(_recogida)

func _recogida(body):
	if body.is_in_group("jugador"): # ← asegúrate de que dusty está en este grupo
		body.sumar_moneda()
		queue_free()
