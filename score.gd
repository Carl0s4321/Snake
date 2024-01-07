extends CanvasLayer

#@onready var screen_size =  get_viewport().size
var button_index = 0

func update_score(score):
	$HUD/ScoreText.text = str(score)
	if score > HighScore.high_score:
		HighScore.high_score = score
		$HUD/HighText2.text = str(score)
	
func update_timer(timer):
	$HUD/TimeText.text = str(timer)

func _ready():
	$GameOverMenu/Cursor.global_position.y = $GameOverMenu/Button.get_child(button_index).global_position.y + 24
	if HighScore.reload == false:
		get_tree().paused = true
	else:
		$GameOverMenu.visible = false
		get_tree().paused = false
		
		$menu_sounds.set_stream(load("res://audio/insertCoin.wav"))
		$menu_sounds.play()
	$HUD/HighText2.text = str(HighScore.high_score)

#func _draw():
	#var bg_rect = Rect2(0,400, 400,100)
	#draw_rect(bg_rect, Color8(43, 94, 1))

func _on_continue_pressed():
	if HighScore.reload == false:
		get_tree().paused = false
		$GameOverMenu.visible = false
		
		$menu_sounds.set_stream(load("res://audio/insertCoin.wav"))
		$menu_sounds.play()
	else:
		get_tree().paused = false
		$GameOverMenu.visible = false
		get_tree().reload_current_scene()
	



func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_main_game_over():
	$GameOverMenu.visible = true
	HighScore.reload = true
	
	$menu_sounds.set_stream(load("res://audio/gameOver.wav"))
	$menu_sounds.play()

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		button_index -= 1
		
	if Input.is_action_just_pressed("ui_down"):
		button_index += 1
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
		if button_index == 0:
			_on_continue_pressed()
		elif button_index == 1:
			_on_menu_pressed()

	button_index = wrapi(button_index, 0, 2)
	$GameOverMenu/Cursor.global_position.y = $GameOverMenu/Button.get_child(button_index).global_position.y + 24




func _on_continue_mouse_entered():
	button_index = 0
	$GameOverMenu/Cursor.global_position.y = $GameOverMenu/Button.get_child(button_index).global_position.y + 24

func _on_menu_mouse_entered():
	button_index = 1
	$GameOverMenu/Cursor.global_position.y = $GameOverMenu/Button.get_child(button_index).global_position.y + 24

