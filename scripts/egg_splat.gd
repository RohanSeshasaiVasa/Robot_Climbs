extends Node2D

@onready var splat: Sprite2D = $Splat
@onready var shells: CPUParticles2D = $Shells
@onready var label: Label = $Label

func _ready() -> void:
	splat.flip_h = randf() < 0.5
	shells.restart()
	
	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 20.0, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)

func setup(cargo: CargoType) -> void:
	$Splat.texture = cargo.splat
	$Shells.color = cargo.shard_color
	$Label.text = "-1 " + cargo.single_name
