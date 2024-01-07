extends AnimatedSprite2D

var animation_name = "none"
var layer = -1
var layer_color = [Color8(255,255,255),Color8(255,255,255),Color8(109,222,29),Color8(219,222,29),Color8(189,25,25),Color8(29,138,222)]

var button_index = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = layer_color[layer]
	speed_scale = 80
	if animation_name != "none":
		play(animation_name)
	pass # Replace with function body.
