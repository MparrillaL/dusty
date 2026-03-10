extends CharacterBody2D

@export var speed: float = 60.0
@export var patrol_distance: float = 50.0

var direction: int = -1
var start_position: Vector2

func _ready():
	start_position = global_position
	$AnimatedSprite2D.play("andar")  # Animación inicial

func _physics_process(delta: float) -> void:
	# Movimiento
	velocity.x = direction * speed
	move_and_slide()

	# Reproducir animación de caminar si no está activa
	if not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("andar")

	# Distancia recorrida
	var distance = abs(global_position.x - start_position.x)

	# Si llega al límite, girar
	if distance >= patrol_distance:
		direction *= -1

		# Ajusta esta línea según cómo esté dibujado tu sprite:
		# Si tu sprite mira a la DERECHA por defecto:
		$AnimatedSprite2D.flip_h = direction > 0
		# Si tu sprite mira a la IZQUIERDA por defecto, usa esto en su lugar:
		# $AnimatedSprite2D.flip_h = direction > 0

		start_position = global_position
