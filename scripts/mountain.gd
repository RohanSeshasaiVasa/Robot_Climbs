extends Node

const GRASS: Texture2D = preload("res://assets/ground_grass.png")
const CLIFF: Texture2D = preload("res://assets/cliff.png")
const ROCK: Texture2D = preload("res://assets/ground_rock.png")
const SNOW: Texture2D = preload("res://assets/ground_snow.png")
const GRASS_TO_ROCK: Texture2D = preload("res://assets/edge_grass_rock.png")
const ROCK_TO_SNOW: Texture2D = preload("res://assets/edge_rock_snow.png")

func _ready() -> void:
	var rock_line := Climb.y_at(Climb.ROCK_START_METERS)
	var snow_line := Climb.y_at(Climb.SNOW_START_METERS)
	
	_add_ground(GRASS, Climb.TOP_Y, Climb.BOTTOM_Y)
	_add_ground(ROCK, snow_line, rock_line)
	_add_ground(SNOW, Climb.TOP_Y, snow_line)
	_add_wall(0.0, false)	
	_add_wall(Climb.MOUNTAIN_WIDTH - Climb.WALL_WIDTH, true)

func _add_ground(texture: Texture2D, top_y: float, bottom_y: float) -> void:
	var ground := Sprite2D.new()
	ground.texture = texture
	ground.centered = false
	ground.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	ground.region_enabled = true
	ground.region_rect = Rect2(0, 0, Climb.MOUNTAIN_WIDTH, bottom_y - top_y)
	ground.position = Vector2(0, top_y)
	ground.z_index = -10
	add_child(ground)

func _add_edge(texture: Texture2D, line_y: float) -> void:
	var edge := Sprite2D.new()
	edge.texture = texture
	edge.centered = false
	edge.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	edge.region_enabled = true
	edge.region_rect = Rect2(0, 0, Climb.MOUNTAIN_WIDTH, texture.get_height())
	edge.position = Vector2(0, line_y - texture.get_height() / 2.0)
	edge.z_index = -10
	add_child(edge)
	
func _add_wall(left_x: float, mirrored: bool) -> void:
	var height := Climb.BOTTOM_Y - Climb.TOP_Y
	var wall := StaticBody2D.new()
	wall.position = Vector2(left_x, Climb.TOP_Y)
	add_child(wall)
	var sprite := Sprite2D.new()
	sprite.texture = CLIFF
	sprite.centered = false
	sprite.flip_h = mirrored
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, Climb.WALL_WIDTH, height)
	sprite.z_index = -9
	wall.add_child(sprite)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(Climb.WALL_WIDTH - 4.0, height)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	var center_x := shape.size.x / 2.0
	if mirrored:
		center_x = Climb.WALL_WIDTH - shape.size.x / 2.0
	collision.position = Vector2(center_x, height / 2.0)
	wall.add_child(collision)
