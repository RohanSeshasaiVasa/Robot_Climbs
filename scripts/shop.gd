extends Area2D

signal cargo_picked_up

var has_cargo_waiting: bool = true

@onready var hint: Label = $Hint

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and has_cargo_waiting:
		has_cargo_waiting = false
		hint.visible = false
		cargo_picked_up.emit()

func reopen(cargo_name: String) -> void:
	has_cargo_waiting = true
	hint.text = "GET %s!" % cargo_name
	hint.visible = true
