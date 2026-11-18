extends Node2D

@onready var dog: CharacterBody2D = $RobotDog
@onready var camera: Camera2D = $RobotDog/Camera2D
@onready var sidebar: CanvasLayer = $Sidebar

func _ready() -> void:
	dog.position = Vector2(Climb.CENTER_X, Climb.START_Y)
	
	camera.limit_left = 0
	camera.limit_right = 480
	camera.limit_top = int(Climb.TOP_Y)
	camera.limit_bottom = int(Climb.BOTTOM_Y)
	camera.reset_smoothing()

func _process(_delta: float) -> void:
	sidebar.set_height(Climb.height_at(dog.position.y))
