extends Node2D

const ROCK_SCENE: PackedScene = preload("res://scenes/rolling-rock.tscn")

@export var dog: Node2D
@export var start_meters: float = 150.0
@export var slowest_gap: float = 4.0
@export var fastest_gap: float = 1.5
@export var warning_time: float = 1.0

var next_rock_x: float = 0.0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var warning_timer: Timer = $WarningTimer
@onready var warning: Sprite2D = $WarningLayer/Warning
@onready var warn_sound: AudioStreamPlayer2D = $WarnSound

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	warning_timer.timeout.connect(_on_warning_timer_timeout)
	
func _process(_delta: float) -> void:
	if warning.visible:
		var blink_on := int(Time.get_ticks_msec() / 120.0) % 2 == 0
		warning.modulate.a = 1.0 if blink_on else 0.3
		
func _on_spawn_timer_timeout() -> void:
	var height := Climb.height_at(dog.position.y)
	if height >= start_meters:
		next_rock_x = randf_range(56.0, Climb.MOUNTAIN_WIDTH - 56.0)
		warning.position.x = next_rock_x
		warning.visible = true
		warning_timer.start(warning_time)
		warn_sound.play()
	
	var progress := height / Climb.SUMMIT_METERS
	spawn_timer.start(lerpf(slowest_gap, fastest_gap, progress))
	
func _on_warning_timer_timeout() -> void:
	warning.visible = false
	var camera_top := get_viewport().get_camera_2d().get_screen_center_position().y - 135.0
	var rock := ROCK_SCENE.instantiate()
	rock.position = Vector2(next_rock_x, camera_top - 16.0)
	add_child(rock)
