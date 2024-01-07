extends CanvasLayer

#@onready var screen_size =  get_viewport().size

func update_score(score):
	$HUD/ScoreText.text = str(score)
	if score > HighScore.high_score:
		HighScore.high_score = score
		$HUD/HighText2.text = str(score)
	
func update_timer(timer):
	$HUD/TimeText.text = str(timer)

func _ready():
	get_tree().paused = false
	$HUD/HighText2.text = str(HighScore.high_score)

#func _draw():
	#var bg_rect = Rect2(0,400, 400,100)
	#draw_rect(bg_rect, Color8(43, 94, 1))

func _on_continue_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	



func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_main_game_over():
	$GameOverMenu.visible = true
