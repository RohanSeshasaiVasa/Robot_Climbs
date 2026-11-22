extends Area2D

@export var speed: float = 70.0
@export var wobble: float = 25.0
@export var lifetime: float = 8.0

var time_alive: float = 0.0
var start_x: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	start_x = position.x
	body_entered.connect(_on_body_entered)
	
func _physics_process(delta: float) -> void:
	time_alive += delta
	position.y += speed * delta
	position.x = start_x + sin(time_alive * 2.0) * wobble
	sprite.rotation += speed / 6.0 * delta
	if time_alive > lifetime:
		queue_free()
		
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hit_by_rock(global_position)
		queue_free()
	elif body.is_in_group("boulders"):
		queue_free()
	
