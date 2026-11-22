extends Node2D

const BOULDER_SCENE: PackedScene = preload("res://scenes/Boulder.tscn")
const ROUGH_SCENE: PackedScene = preload("res://scenes/rough_ground.tscn")

const LEFT: float = Climb.WALL_WIDTH + 24.0
const RIGHT: float = Climb.MOUNTAIN_WIDTH - Climb.WALL_WIDTH - 24.0

@export var first_row_meters: float = 20.0
@export var row_gap_meters: float = 12.0
@export var clear_below_summit: float = 15.0

func _ready() -> void:
	var meters := first_row_meters
	while meters < Climb.SUMMIT_METERS - clear_below_summit:
		var difficulty := meters / Climb.SUMMIT_METERS
		_make_row(Climb.y_at(meters), difficulty)
		meters += row_gap_meters * randf_range(0.7, 1.3)
		
func _make_row(y: float, difficulty: float) -> void:
	var roll := randf()
	if roll < 0.4:
		var most := 1 + roundi(difficulty * 2.0)
		_add_boulders(y, randi_range(1, most))
	elif roll < 0.75:
		_add_rough_patch(y, difficulty)
	else:
		_add_rough_patch(y, difficulty)
		_add_boulders(y - 40.0, 1)
		
func _add_boulders(y: float, count: int) -> void:
	var lanes := [0, 1, 2]
	lanes.shuffle()
	var lane_width := (RIGHT - LEFT) / 3.0
	for i in count:
		var boulder := BOULDER_SCENE.instantiate()
		var x: float = LEFT + lanes[i] * lane_width + randf_range(25.0, lane_width - 25.0)
		boulder.position = Vector2(x, y + randf_range(-20.0, 20.0))
		add_child(boulder)
		
func _add_rough_patch(y: float, difficulty: float) -> void:
	var patch := ROUGH_SCENE.instantiate()
	var full_width := randf() < difficulty * 0.5
	var size := Vector2.ZERO
	if full_width:
		size = Vector2(Climb.MOUNTAIN_WIDTH - Climb.WALL_WIDTH * 2.0, randf_range(40.0, 56.0))
	else:
		size.x = randf_range(80.0, 160.0 + 80.0 * difficulty)
		size.y = randf_range(40.0, 64.0 + 24.0 * difficulty)
	
	var half := size.x / 2.0
	var x := randf_range(Climb.WALL_WIDTH + half, Climb.MOUNTAIN_WIDTH - Climb.WALL_WIDTH - half)
	
	patch.patch_size = size
	add_child(patch)
