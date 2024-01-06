extends CanvasLayer

#@onready var screen_size =  get_viewport().size

func update_score(snake_length):
	$ScoreText.text = str(snake_length-3)
	
func update_timer(timer):
	$TimeText.text = str(timer)

func _ready():
	pass

#func _draw():
	#var bg_rect = Rect2(0,400, 400,100)
	#draw_rect(bg_rect, Color8(43, 94, 1))

