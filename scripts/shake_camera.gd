extends Camera2D

@export var decay: float = 8.0

var strength: float = 0.0
var base_offset: Vector2

func _ready() -> void:
	base_offset = offset
	
func shake(amount: float) -> void:
	strength = maxf(strength, amount)
	
func _process(delta: float) -> void:
	if strength > 0.0:
		offset = base_offset + Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		strength = move_toward(strength, 0.0, decay * delta)
	else:
		offset = base_offset
