extends Node2D

var is_kill = false

func set_text(string):
	$Label.text = str(string)
# Called when the node enters the scene tree for the first time.
func _ready():
	if is_kill:
		$AnimationPlayer.play("kill")
	else:
		$AnimationPlayer.play("float")
	


func _on_animation_player_animation_finished(anim_name):
	queue_free()
