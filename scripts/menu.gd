extends Control

@onready var play_button: Button = %PlayButton
@onready var about_button: Button = %AboutButton
@onready var leave_button: Button = %LeaveButton
@onready var about_panel: Panel = %AboutPanel
@onready var back_button: Button = %BackButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	about_button.pressed.connect(_on_about_pressed)
	leave_button.pressed.connect(_on_leave_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	for button in [play_button, about_button, leave_button, back_button]:
		_style_button(button)
		
	var box := StyleBoxFlat.new()
	box.bg_color = Color("1a1c2c")
	box.border_color = Color("94b0c2")
	box.set_border_width_all(1)
	about_panel.add_theme_stylebox_override("panel", box)
	about_panel.visible = false
	play_button.grab_focus()
	
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_about_pressed() -> void:
	about_panel.visible = true
	back_button.grab_focus()
	
func _on_back_pressed() -> void:
	about_panel.visible = false
	about_button.grab_focus()
	
func _on_leave_pressed() -> void:
	get_tree().quit()
	
func _style_button(button: Button) -> void:
	var looks := {
		"normal": Color("333c57"),
		"hover": Color("566c86"),
		"focus": Color("566c86"),
		"pressed": Color("ef7d57"),
	}
	for state in looks:
		var box := StyleBoxFlat.new()
		box.bg_color = looks[state]
		box.border_color = Color("94b0c2")
		box.set_border_width_all(1)
		button.add_theme_stylebox_override(state, box)
