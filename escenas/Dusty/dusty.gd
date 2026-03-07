extends CharacterBody2D

@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D
var _velocidad: float = 100.0
var _velocidad_salto: float = -300.0
var monedas: int = 0

func _ready():
	pass

	# monedas
func sumar_moneda():
	monedas += 1
	
	

func _physics_process(delta):
	# gravedad
	velocity += get_gravity() * delta

	# salto
	if Input.is_action_just_pressed("salto") and is_on_floor():
		velocity.y = _velocidad_salto
		animacion.play("salto")

	# movimiento lateral
	if Input.is_action_pressed("izquierda"):
		velocity.x = -_velocidad
		animacion.flip_h = true
	elif Input.is_action_pressed("derecha"):
		velocity.x = _velocidad
		animacion.flip_h = false
	else:
		velocity.x = 0

	move_and_slide()

	# -------------------------
	# SISTEMA DE ANIMACIONES
	# -------------------------

	# 1. Si está en el aire → salto o caída
	if !is_on_floor():
		if velocity.y < 0:
			# subiendo
			if animacion.animation != "salto":
				animacion.play("salto")
		else:
			# bajando
			if animacion.animation != "caer":
				animacion.play("caer")
		return  # IMPORTANTE: evita que se reproduzcan otras animaciones

	# 2. Si está en el suelo → idle o andar
	if velocity.x == 0:
		if animacion.animation != "idle":
			animacion.play("idle")
	else:
		if animacion.animation != "andar":
			animacion.play("andar")

	# muerte 
func die():
	var sprite = $animacion
	var original_scale = sprite.scale

	set_physics_process(false)
	set_process(false)

	var t = create_tween()

	# Flash blanco retro
	t.tween_property(sprite, "modulate", Color(1,1,1,1), 0.05)

	# Glitch color
	t.tween_property(sprite, "modulate", Color(1,0.3,1,1), 0.1)

	# Glitch de escala RELATIVO
	t.parallel().tween_property(sprite, "scale", original_scale * Vector2(1.3, 0.7), 0.1)
	t.parallel().tween_property(sprite, "rotation_degrees", -10, 0.1)

	# Segundo glitch
	t.tween_property(sprite, "scale", original_scale * Vector2(0.8, 1.4), 0.1)
	t.parallel().tween_property(sprite, "rotation_degrees", 8, 0.1)

	# Fade-out moderno + explosión final
	t.tween_property(sprite, "modulate:a", 0.0, 0.15)
	t.parallel().tween_property(sprite, "scale", original_scale * Vector2(1.4, 1.4), 0.15)
	t.parallel().tween_property(sprite, "rotation_degrees", 20, 0.15)

	# Reiniciar escena
	t.tween_callback(func():
		get_tree().reload_current_scene()
		)
	
	
func _on_area_2d_area_entered(area):
	if area.name == "kill_zone":
		die()  # o la función que uses para matar/reiniciar
