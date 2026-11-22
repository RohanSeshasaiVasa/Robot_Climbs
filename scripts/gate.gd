extends StaticBody2D

func open() -> void:
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
func close() -> void:
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)
