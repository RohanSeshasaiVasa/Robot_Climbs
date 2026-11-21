extends Node2D

var climb_time: float = 0.0

@onready var dog: CharacterBody2D = $RobotDog
@onready var camera: Camera2D = $RobotDog/Camera2D
@onready var sidebar: CanvasLayer = $Sidebar
@onready var summit: Area2D = $Summit
@onready var end_screen: CanvasLayer = $EndScreen

func _ready() -> void:
	dog.position = Vector2(Climb.CENTER_X, Climb.START_Y)
	summit.position = Vector2(Climb.CENTER_X, Climb.SUMMIT_Y)
	summit.reached.connect(_on_summit_reached)
	dog.out_of_eggs.connect(_on_out_of_eggs)
	sidebar.setup_eggs(dog.start_eggs)
	dog.eggs_changed.connect(sidebar.set_eggs)
	camera.limit_left = 0
	camera.limit_right = 480
	camera.limit_top = int(Climb.TOP_Y)
	camera.limit_bottom = int(Climb.BOTTOM_Y)
	camera.reset_smoothing()

func _process(delta: float) -> void:
	climb_time += delta
	sidebar.set_height(Climb.height_at(dog.position.y))

func _on_summit_reached() -> void:
	var minutes := floori(climb_time / 60.0)
	var seconds := floori(climb_time) % 60
	end_screen.show_message(
		"YOU REACHED THE PEAK !",
		"%d m in %d:%02d" % [int(Climb.SUMMIT_METERS), minutes, seconds]
	)

func _on_out_of_eggs() -> void:
	end_screen.show_message(
		"ALL THE EGGS BROKE !!",
		"YOU GOT TO %d m" % int(Climb.height_at(dog.position.y))
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		dog.break_egg()
