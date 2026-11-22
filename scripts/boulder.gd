extends StaticBody2D

func _ready() -> void:
	$Sprite2D.frame = randi() % 2
	$Sprite2D.flip_h = randf() < 0.5
