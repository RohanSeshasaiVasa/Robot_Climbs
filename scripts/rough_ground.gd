extends Area2D

@export var patch_size: Vector2 = Vector2(128, 64)

@onready var patch: NinePatchRect = $Patch
@onready var collision: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_index = -8
	patch.size = patch_size
	patch.position = -patch_size / 2.0
	var shape := RectangleShape2D.new()
	shape.size = patch_size - Vector2(8, 8)
	collision.shape = shape
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.enter_rough_ground()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.exit_rough_ground()
