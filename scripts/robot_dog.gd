extends CharacterBody2D

const STEP_LENGTH: float = Climb.METER

@export var max_speed: float = 200.0
@export var acceleration: float = 500.0
@export var friction: float = 650.0
@export var max_lean: float = 0.25

var walk_distance: float = 0.0

@onready var body: Sprite2D = $Body

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
	_animate(delta)

func _animate(delta: float) -> void:
	var speed := velocity.length()
	
	if speed > 5.0:
		walk_distance += speed * delta
		var frame_number := int(walk_distance / (STEP_LENGTH / 2.0))
		body.frame = frame_number %4
	else:
		body.frame = 1
		
	var target_lean := velocity.x / max_speed * max_lean
	body.rotation = lerp_angle(body.rotation, target_lean, 10.0 * delta)
