extends CanvasLayer

var title_label: Label
var info_label: Label

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.size = Vector2(480, 270)
	add_child(dim)
	
	title_label = _add_label(100, Color("ffcd75"))
	title_label.add_theme_font_size_override("font_size", 16)
	info_label = _add_label(136, Color("f4f4f4"))
	var hint := _add_label(200, Color("94b0c2"))
	hint.text = "PRESS R TO CLIMB AGAIN"

func show_message(title: String, info: String) -> void:
	title_label.text = title
	info_label.text = info
	visible = true
	get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()

func _add_label(y: float, color: Color) -> Label:
	var label := Label.new()
	label.position = Vector2(0, y)
	label.size = Vector2(480, 8)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label
