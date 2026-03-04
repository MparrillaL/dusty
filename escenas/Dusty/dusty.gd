extends CharacterBody2D

@export var animacion: AnimatedSprite2D

var _velocidad: float = 100.0
var _velocidad_salto: float = -300.0
var monedas: int = 0
signal monedas_cambiaron(nuevo_valor)
	# monedas
func sumar_moneda():
	monedas += 1
	emit_signal("moneda_cambiaron", monedas)
	

func _physics_process(delta):
	# gravedad
	velocity += get_gravity() * delta

	# salto
	if Input.is_action_just_pressed("salto") and is_on_floor():
		velocity.y = _velocidad_salto

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

	# animación
	if !is_on_floor():
		animacion.play("salto")
	elif velocity.x != 0:
		animacion.play("andar")
	else:
		animacion.play("idle")
