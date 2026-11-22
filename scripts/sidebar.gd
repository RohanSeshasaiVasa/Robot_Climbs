extends CanvasLayer

const MOUNTAIN_PICTURE: Texture2D = preload("res://assets/sidebar_mountain.png")
const DOG_MARKER: Texture2D = preload("res://assets/dog_marker.png")
const EGG_ICON: Texture2D = preload("res://assets/egg_icon.png")
const EGG_BROKEN_ICON: Texture2D = preload("res://assets/egg_broken_icon.png")

const WIDTH = 96.0
const BACKGROUND := Color("1a1c2c")
const BORDER := Color("333c57")
const TEXT_DIM := Color("94b0c2")
const DANGER := Color("b13e53")
const TEXT_BRIGHT := Color("ffcd75")
const EGGS_PER_ROW: int = 6
const EGG_SPACING: float = 10.0
const EGGS_TOP: float = 206.0

var panel: Panel
var mountain: TextureRect
var marker: TextureRect
var height_value: Label
var egg_icons: Array[TextureRect] = []
var shake_bar: ProgressBar
var shake_fill: StyleBoxFlat

func _ready() -> void:
	panel = Panel.new()
	panel.position = Vector2(Climb.MOUNTAIN_WIDTH, 0)
	panel.size = Vector2(WIDTH, 270)
	var style := StyleBoxFlat.new()
	style.bg_color = BACKGROUND
	style.border_color = BORDER
	style.border_width_left = 2
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	_add_label(panel, "ROBOT\nCLIMBS", 6, Color.WHITE)
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
		
	_add_label(panel, "EGGS", 194, TEXT_DIM)
	_add_label(panel, "SHAKE", 232, TEXT_DIM)
	shake_bar = ProgressBar.new()
	shake_bar.position = Vector2(12, 244)
	shake_bar.size = Vector2(WIDTH - 24, 12)
	shake_bar.max_value = 1.0
	shake_bar.show_percentage = false
	var bar_back := StyleBoxFlat.new()
	bar_back.bg_color = BORDER
	shake_fill = StyleBoxFlat.new()
	shake_fill.bg_color = TEXT_BRIGHT
	shake_bar.add_theme_stylebox_override("backgorund", bar_back)
	shake_bar.add_theme_stylebox_override("fill", shake_fill)
	panel.add_child(shake_bar)
	set_height(0.0)
	
func set_height(meters: float) -> void:
	height_value.text = "%d m" % int(meters)
	
	var progress := meters / Climb.SUMMIT_METERS
	var bottom_y := MOUNTAIN_PICTURE.get_height() - DOG_MARKER.get_height()
	var top_y := 4.0
	var x := (MOUNTAIN_PICTURE.get_width() - DOG_MARKER.get_width()) / 2.0
	marker.position = Vector2(x, lerpf(bottom_y, top_y, progress))
	
func setup_eggs(total: int) -> void:
	var icons_in_row := mini(total, EGGS_PER_ROW)
	var row_width := icons_in_row * EGG_SPACING - 2.0
	var left := (WIDTH - row_width) / 2.0
	
	for i in total:
		var icon := TextureRect.new()
		icon.texture = EGG_ICON
		var column := i % EGGS_PER_ROW
		var row := floori(float(i) / EGGS_PER_ROW)
		icon.position = Vector2(left + column * EGG_SPACING, EGGS_TOP + row * 12.0)
		panel.add_child(icon)
		egg_icons.append(icon)

func set_eggs(eggs_left: int) -> void:
	for i in egg_icons.size():
		if i < eggs_left:
			egg_icons[i].texture = EGG_ICON
		else:
			egg_icons[i].texture = EGG_BROKEN_ICON

func set_shake(amount: float) -> void:
	shake_bar.value = amount
	shake_fill.bg_color = TEXT_BRIGHT.lerp(DANGER, amount)

func _add_label(parent: Control, text: String, y: float, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = Vector2(0, y)
	label.size = Vector2(WIDTH, 8)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label
