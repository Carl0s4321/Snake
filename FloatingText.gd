extends Node2D

func set_text(string):
	$Node2D/Label.text = str(string)
# Called when the node enters the scene tree for the first time.
func _ready():
	
	$AnimationPlayer.play("float")


func _on_animation_player_animation_finished(anim_name):
	queue_free()
