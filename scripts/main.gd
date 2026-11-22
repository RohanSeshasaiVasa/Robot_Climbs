extends Node2D

const EGG_SPLAT: PackedScene = preload("res://scenes/egg_splat.tscn")

@export var delivery_goal: int = 10
@export var cargo_by_trip: Array[CargoType] = []

var climb_time: float = 0.0
var trip: int = 1
var delivered: int = 0

@onready var dog: CharacterBody2D = $RobotDog
@onready var camera: Camera2D = $RobotDog/Camera2D
@onready var sidebar: CanvasLayer = $Sidebar
@onready var summit: Area2D = $Summit
@onready var end_screen: CanvasLayer = $EndScreen
@onready var effects: Node2D = $Effects
@onready var crack_sound: AudioStreamPlayer2D = $Sounds/Crack
@onready var bump_sound: AudioStreamPlayer2D = $Sounds/Bump
@onready var win_sound: AudioStreamPlayer2D = $Sounds/Win
@onready var lose_sound: AudioStreamPlayer2D = $Sounds/Lose
@onready var shop: Area2D = $Shop
@onready var gate: StaticBody2D = $Gate
@onready var dog_start: Marker2D = $DogStart
@onready var fade: ColorRect = $Fade/Black
@onready var fade_message: Label = $Fade/Black/Message

func _ready() -> void:
	dog.position = dog_start.position
	summit.position = Vector2(Climb.CENTER_X, Climb.SUMMIT_Y)
	summit.reached.connect(_on_summit_reached)
	dog.out_of_eggs.connect(_on_out_of_eggs)
	shop.cargo_picked_up.connect(_on_cargo_picked_up)
	shop.reopen(_cargo_for_trip().display_name)
	sidebar.set_delivered(delivered, delivery_goal)
	dog.eggs_changed.connect(sidebar.set_eggs)
	dog.shake_changed.connect(sidebar.set_shake)
	dog.eggs_changed.connect(_on_egg_broken)
	dog.bumped.connect(bump_sound.play)
	camera.limit_left = 0
	camera.limit_right = 480
	camera.limit_top = int(Climb.TOP_Y)
	camera.limit_bottom = int(Climb.BOTTOM_Y)
	camera.reset_smoothing()

func _process(delta: float) -> void:
	climb_time += delta
	sidebar.set_height(Climb.height_at(dog.position.y))

func _on_summit_reached() -> void:
	delivered += dog.eggs
	sidebar.set_delivered(delivered, delivery_goal)
	
	if delivered >= delivery_goal:
		win_sound.play()
		var minutes := floori(climb_time / 60.0)
		var seconds := floori(climb_time) % 60
		end_screen.show_message(
			"YOU REACHED THE PEAK",
			"%d DELIVERED TRIPS: %d  %d:%02d" % [delivered, trip, minutes, seconds]
		)
	else:
		_send_back_to_shop()
		
func _send_back_to_shop() -> void:
	dog.set_physics_process(false)
	trip += 1
	var next_cargo := _cargo_for_trip()
	var still_needed := delivery_goal - delivered
	fade_message.text = "%d DELIVERED THIS TRIP.\n%d MORE TO GO!\n\nBACK TO THE SHOP FOR %s..." % [dog.eggs, still_needed, next_cargo.display_name]

	var fade_out := create_tween()
	fade_out.tween_property(fade, "modulate:a", 1.0, 0.6)
	await fade_out.finished

	# The screen is black now: set up the next trip.
	dog.position = dog_start.position
	dog.velocity = Vector2.ZERO
	dog.empty_basket()
	sidebar.setup_eggs(0)
	shop.reopen(next_cargo.display_name)
	gate.close()
	summit.reset()
	camera.reset_smoothing()

	await get_tree().create_timer(1.5).timeout  # time to read the message

	var fade_in := create_tween()
	fade_in.tween_property(fade, "modulate:a", 0.0, 0.6)
	await fade_in.finished
	dog.set_physics_process(true)
	
func _on_out_of_eggs() -> void:
	dog.set_physics_process(false)
	await get_tree().create_timer(1.0).timeout
	lose_sound.play()
	end_screen.show_message(
		"ALL THE %s BROKE!" % dog.cargo.display_name,
		"YOU GOT TO %d m" % int(Climb.height_at(dog.position.y))
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		dog.break_egg()

func _on_egg_broken(_eggs_left: int) -> void:
	var splat := EGG_SPLAT.instantiate()
	splat.setup(dog.cargo)
	splat.position = dog.position
	effects.add_child(splat)
	camera.shake(3.0)
	crack_sound.pitch_scale = randf_range(0.9, 1.15)
	crack_sound.play()

func _cargo_for_trip() -> CargoType:
	var index := mini(trip, cargo_by_trip.size()) - 1
	return cargo_by_trip[index]

func _on_cargo_picked_up() -> void:
	var cargo := _cargo_for_trip()
	dog.load_cargo(cargo)
	sidebar.setup_cargo(cargo)
	gate.open()
