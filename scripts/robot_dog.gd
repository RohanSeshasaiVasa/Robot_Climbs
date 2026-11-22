extends CharacterBody2D

signal eggs_changed(eggs_left: int)
signal out_of_eggs
signal shake_changed(amount: float)
signal bumped

const STEP_LENGTH: float = Climb.METER

@export var max_speed: float = 600.0
@export var acceleration: float = 500.0
@export var friction: float = 650.0
@export var max_lean: float = 0.25
@export var safe_speed: float = 40.0
@export var shake_gain: float = 0.03
@export var shake_recovery: float = 0.5
@export var bump_speed: float = 60.0
@export var bounce: float = 50.0
@export var careful_factor: float = 0.3

var cargo: CargoType = null
var eggs: int = 0
var shake: float = 0.0
var rough_patches: int = 0
var walk_distance: float = 0.0

@onready var body: Sprite2D = $Body
@onready var basket: Sprite2D = $Body/Basket

func _ready() -> void:
	eggs = 0
	_update_basket()

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * get_top_speed(), acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	var velocity_before := velocity
	move_and_slide()
	_check_bumps(velocity_before)
	_update_shake(delta)
	_animate(delta)

func get_top_speed() -> float:
	var weight_per_item := 0.0
	if cargo != null:
		weight_per_item = cargo.weight
	var speed := max_speed - eggs * weight_per_item
	if Input.is_action_pressed("careful"):
		speed *= careful_factor
	return speed

func enter_rough_ground() -> void:
	rough_patches += 1

func exit_rough_ground() -> void:
	rough_patches -= 1

func break_egg() -> void:
	if eggs <= 0:
		return
	eggs -= 1
	_update_basket()
	eggs_changed.emit(eggs)
	if eggs == 0:
		out_of_eggs.emit()

func _update_shake(delta: float) -> void:
	var speed := velocity.length()
	if rough_patches > 0 and speed > safe_speed:
		shake += (speed - safe_speed) * shake_gain * get_fragility() * delta
	else:
		shake = maxf(shake - shake_recovery * delta, 0.0)
		
	if shake >= 1.0:
		shake = 0.0
		break_egg()
	shake_changed.emit(shake)

func _check_bumps(velocity_before: Vector2) -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var normal := collision.get_normal()
		var impact := -velocity_before.dot(normal)
		var break_speed := bump_speed / get_fragility()
		if collision.get_collider().is_in_group("boulders") and impact > break_speed:
			velocity = normal * minf(bounce, break_speed * 0.6)
			bumped.emit()
			break_egg()
			return
		velocity = velocity.slide(normal)

func hit_by_rock(rock_position: Vector2) -> void:
	if not is_physics_processing():
		return
	velocity = (global_position - rock_position).normalized() * bounce * 2.0
	bumped.emit()
	break_egg()

func _update_basket() -> void:
	basket.frame = mini(eggs, basket.hframes - 1)

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
	
	if rough_patches > 0 and speed > 5.0:
		var rattle := 0.5 + shake * 1.5
		body.position = Vector2(randf_range(-rattle, rattle), randf_range(-rattle, rattle))
	else:
		body.position = Vector2.ZERO

func empty_basket() -> void:
	eggs = 0
	shake = 0.0
	_update_basket()

func load_cargo(new_cargo: CargoType) -> void:
	cargo = new_cargo
	eggs = cargo.count
	basket.texture = cargo.basket
	basket.hframes = cargo.count + 1
	_update_basket()

func get_fragility() -> float:
	if cargo == null:
		return 1.0
	return cargo.fragility
