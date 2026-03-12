extends CharacterBody2D

@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D

@export_group("Movimiento")
@export_range(0.0, 1000.0, 10.0) var velocidad: float = 100.0
@export_range(0.0, 2000.0, 10.0) var velocidad_salto: float = 300.0
@export_range(0.0, 10.0, 0.5) var multiplicador_sprint: float = 1.5

const EPSILON_MOVIMIENTO := 0.01

var monedas: int = 0
var vel_actual: float = 0.0   # ← variable global, ya no se sobrescribe

func _ready() -> void:
	if animacion == null:
		push_warning("No se asignó AnimatedSprite2D en 'animacion'.")


func sumar_moneda() -> void:
	monedas += 1


func _physics_process(delta: float) -> void:
	# gravedad
	velocity += get_gravity() * delta

	# salto
	if Input.is_action_just_pressed("salto") and is_on_floor():
		velocity.y = -velocidad_salto
		_play_anim_if_needed("salto")

	# --------------------------------
	# MOVIMIENTO LATERAL CORREGIDO
	# --------------------------------
	vel_actual = velocidad

	if Input.is_action_pressed("sprint"):
		vel_actual *= multiplicador_sprint   # ← sprint correcto

	if Input.is_action_pressed("izquierda"):
		velocity.x = -vel_actual
		if animacion:
			animacion.flip_h = true

	elif Input.is_action_pressed("derecha"):
		velocity.x = vel_actual
		if animacion:
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
			_play_anim_if_needed("salto")
		else:
			_play_anim_if_needed("caer")
		return

	# 2. Si está en el suelo → idle o andar
	if abs(velocity.x) < EPSILON_MOVIMIENTO:
		_play_anim_if_needed("idle")
	else:
		_play_anim_if_needed("andar")


func _play_anim_if_needed(nombre_animacion: StringName) -> void:
	if animacion == null:
		return
	if animacion.animation != nombre_animacion:
		animacion.play(nombre_animacion)


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
