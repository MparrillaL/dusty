extends CharacterBody2D

@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D

@export_group("Movimiento")
@export_range(0.0, 1000.0, 10.0) var velocidad: float = 120.0
@export_range(0.0, 2000.0, 10.0) var velocidad_salto: float = 350.0
@export_range(0.0, 10.0, 0.1) var multiplicador_sprint: float = 1.5

# Físicas estilo Hollow Knight
var aceleracion_suelo := 2000.0
var desaceleracion_suelo := 1800.0
var aceleracion_aire := 1200.0
var desaceleracion_aire := 900.0

const EPSILON_MOVIMIENTO := 0.01

var monedas: int = 0
var vel_actual: float = 0.0
var ha_saltado := false   # ← evita animaciones de salto falsas
var salto_con_sprint := false


func _physics_process(delta: float) -> void:
	# gravedad
	velocity += get_gravity() * delta

	# salto
	if Input.is_action_just_pressed("salto") and is_on_floor():
		salto_con_sprint = Input.is_action_pressed("sprint")
		velocity.y = -velocidad_salto
		ha_saltado = true
		_play_anim_if_needed("salto")

	# --------------------------------
	# MOVIMIENTO LATERAL + SPRINT
	# --------------------------------
	vel_actual = velocidad

	# Sprint solo si está en el suelo
	var sprint_activo := is_on_floor() and Input.is_action_pressed("sprint")
	if sprint_activo:
		vel_actual *= multiplicador_sprint

	# Dirección del input
	var input_dir := 0.0
	if Input.is_action_pressed("izquierda"):
		input_dir = -1.0
		if animacion:
			animacion.flip_h = true
	elif Input.is_action_pressed("derecha"):
		input_dir = 1.0
		if animacion:
			animacion.flip_h = false

	# Aceleración estilo Hollow Knight
	var acel := aceleracion_suelo if is_on_floor() else aceleracion_aire
	var desacel := desaceleracion_suelo if is_on_floor() else desaceleracion_aire
	var vel_objetivo := vel_actual if is_on_floor() else velocidad * (multiplicador_sprint if salto_con_sprint else 1.0)

	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * vel_objetivo, acel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, desacel * delta)

	move_and_slide()

	# Reset del salto al tocar suelo
	if is_on_floor():
		ha_saltado = false
		salto_con_sprint = false

	# -------------------------
	# SISTEMA DE ANIMACIONES
	# -------------------------

	# 1. Animaciones en el aire
	if !is_on_floor():
		if ha_saltado:
			if velocity.y < 0:
				_play_anim_if_needed("salto")
			else:
				_play_anim_if_needed("caer")
		else:
			# No reproducir salto si solo baja una rampa o escalón
			pass
		return

	# 2. Animaciones en el suelo
	if abs(velocity.x) < EPSILON_MOVIMIENTO:
		_play_anim_if_needed("idle")
	else:
		if sprint_activo:
			_play_anim_if_needed("correr")  # ← animación de sprint
		else:
			_play_anim_if_needed("andar")


func _play_anim_if_needed(nombre_animacion: StringName) -> void:
	if animacion == null:
		return
	if animacion.animation != nombre_animacion:
		animacion.play(nombre_animacion)


func sumar_moneda() -> void:
	monedas += 1


func die() -> void:
	if animacion == null:
		get_tree().reload_current_scene()
		return

	var sprite := animacion
	var original_scale = sprite.scale

	set_physics_process(false)
	set_process(false)

	var t = create_tween()

	t.tween_property(sprite, "modulate", Color(1,1,1,1), 0.05)
	t.tween_property(sprite, "modulate", Color(1,0.3,1,1), 0.1)

	t.parallel().tween_property(sprite, "scale", original_scale * Vector2(1.3, 0.7), 0.1)
	t.parallel().tween_property(sprite, "rotation_degrees", -10, 0.1)

	t.tween_property(sprite, "scale", original_scale * Vector2(0.8, 1.4), 0.1)
	t.parallel().tween_property(sprite, "rotation_degrees", 8, 0.1)

	t.tween_property(sprite, "modulate:a", 0.0, 0.15)
	t.parallel().tween_property(sprite, "scale", original_scale * Vector2(1.4, 1.4), 0.15)
	t.parallel().tween_property(sprite, "rotation_degrees", 20, 0.15)

	t.tween_callback(func():
		get_tree().reload_current_scene()
	)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "kill_zone":
		die()
