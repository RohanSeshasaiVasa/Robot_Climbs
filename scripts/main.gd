extends Node2D

const EGG_SPLAT: PackedScene = preload("res://scenes/egg_splat.tscn")

var climb_time: float = 0.0

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


func _ready() -> void:
	dog.position = Vector2(Climb.CENTER_X, Climb.START_Y)
	summit.position = Vector2(Climb.CENTER_X, Climb.SUMMIT_Y)
	summit.reached.connect(_on_summit_reached)
	dog.out_of_eggs.connect(_on_out_of_eggs)
	sidebar.setup_eggs(dog.start_eggs)
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
	win_sound.play()
	var minutes := floori(climb_time / 60.0)
	var seconds := floori(climb_time) % 60
	end_screen.show_message(
		"YOU REACHED THE PEAK !",
		"%d m in %d:%02d" % [int(Climb.SUMMIT_METERS), minutes, seconds]
	)

func _on_out_of_eggs() -> void:
	dog.set_physics_process(false)
	await get_tree().create_timer(1.0).timeout
	lose_sound.play()
	end_screen.show_message(
		"ALL THE EGGS BROKE !!",
		"YOU GOT TO %d m" % int(Climb.height_at(dog.position.y))
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		dog.break_egg()

func _on_egg_broken(_eggs_left: int) -> void:
	var splat := EGG_SPLAT.instantiate()
	splat.position = dog.position
	effects.add_child(splat)
	camera.shake(3.0)
	crack_sound.pitch_scale = randf_range(0.9, 1.15)
	crack_sound.play()
