extends CanvasLayer

const MOUNTAIN_PICTURE: Texture2D = preload("res://assets/sidebar_mountain.png")
const DOG_MARKER: Texture2D = preload("res://assets/dog_marker.png")

const WIDTH = 96.0
const BACKGROUND := Color("1a1c2c")
const BORDER := Color("333c57")
const TEXT_DIM := Color("94b0c2")
const TEXT_BRIGHT := Color("ffcd75")

var mountain: TextureRect
var marker: TextureRect
var height_value: Label

func _ready() -> void:
	var panel := Panel.new()
	panel.position = Vector2(Climb.MOUNTAIN_WIDTH, 0)
	panel.size = Vector2(WIDTH, 270)
	var style := StyleBoxFlat.new()
	style.bg_color = BACKGROUND
	style.border_color = BORDER
	style.border_width_left = 2
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	_add_label(panel, "ROBOT\nClimbs", 6, Color.WHITE)
	mountain = TextureRect.new()
	mountain.texture = MOUNTAIN_PICTURE
	mountain.position = Vector2((WIDTH - MOUNTAIN_PICTURE.get_width()) / 2.0, 32)
	panel.add_child(mountain)
	
	marker = TextureRect.new()
	marker.texture = DOG_MARKER
	mountain.add_child(marker)
	
	_add_label(panel, "HEIGHT", 152, TEXT_DIM)
	height_value = _add_label(panel, "0 m", 164, TEXT_BRIGHT)
	_add_label(panel, "of %d m" % int(Climb.SUMMIT_METERS), 176, TEXT_DIM)
	
	set_height(0.0)
	
func set_height(meters: float) -> void:
	height_value.text = "%d m" % int(meters)
	
	var progress := meters / Climb.SUMMIT_METERS
	var bottom_y := MOUNTAIN_PICTURE.get_height() - DOG_MARKER.get_height()
	var top_y := 4.0
	var x := (MOUNTAIN_PICTURE.get_width() - DOG_MARKER.get_width()) / 2.0
	marker.position = Vector2(x, lerpf(bottom_y, top_y, progress))
	
func _add_label(parent: Control, text: String, y: float, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = Vector2(0, y)
	label.size = Vector2(WIDTH, 8)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label
