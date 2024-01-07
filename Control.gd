extends Control

var button_index = 0

func _on_start_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	
func _ready():
	get_parent().get_node("Cursor")

func _on_settings_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		button_index -= 1
	if Input.is_action_just_pressed("ui_down"):
		button_index += 1
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
		if button_index == 0:
			_on_start_pressed()
		elif button_index == 1:
			_on_settings_pressed()
		elif button_index == 2:
			_on_quit_pressed()
	button_index = wrapi(button_index, 0, 3)
	get_parent().get_node("Cursor").global_position.y = $MarginContainer/VBoxContainer.get_child(button_index).global_position.y + 24


func _on_start_mouse_entered():
	button_index = 0
	get_parent().get_node("Cursor").global_position.y = $MarginContainer/VBoxContainer.get_child(button_index).global_position.y + 24

func _on_settings_mouse_entered():
	button_index = 1
	get_parent().get_node("Cursor").global_position.y = $MarginContainer/VBoxContainer.get_child(button_index).global_position.y + 24

func _on_quit_mouse_entered():
	button_index = 2
	get_parent().get_node("Cursor").global_position.y = $MarginContainer/VBoxContainer.get_child(button_index).global_position.y + 24


