extends Area2D

signal reached

var is_reached: bool = false
@onready var flag: Sprite2D = $Flag

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	flag.frame = int(Time.get_ticks_msec() / 250.0) % 2
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_reached:
		is_reached = true
		reached.emit()
