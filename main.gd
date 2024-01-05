extends Node

#const SNAKE = 1
const APPLE = 0
var apple_pos
var add_apples = false

const SNAKE_PARTS = {
	"empty":6,
	"body-horizontal":7,
	"body-ne":8,
	"body-nw":9,
	"body-se":10,
	"body-sw":11,
	"body-vertical":12,
	"head-down":14,
	"head-left":15,
	"head-right":16,
	"head-up":17,
	"tail-down":18,
	"tail-left":19,
	"tail-right":20,
	"tail-up":21,
	"body-move-down":13,
	"body-move-left":22,
	"body-move-right":23,
	"body-move-up":24,
	"head-exit-down":25,
	"head-exit-left":26,
	"head-exit-right":27,
	"head-exit-up":28,
	"head-move-down":29,
	"head-move-left":30,
	"head-move-right":31,
	"head-move-up":32,
	"ne-move-right":33,
	"ne-move-up":34,
	"ne-turn-right":35,
	"ne-turn-up":36,
	"nw-move-left":37,
	"nw-move-up":38,
	"nw-turn-left":39,
	"nw-turn-up":40,
	"se-move-down":41,
	"se-move-right":42,
	"se-turn-down":43,
	"se-turn-right":44,
	"sw-move-down":45,
	"sw-move-left":46,
	"sw-turn-down":47,
	"sw-turn-left":48,
	"tail-move-down":49,
	"tail-move-left":50,
	"tail-move-right":51,
	"tail-move-up":52,
	
}

var snake_body = [Vector2(5,10),Vector2(4,10),Vector2(3,10),Vector2(2,10)]
var snake_direction  = Vector2(1,0)
var previous_direction = "right"
func draw_snake():
	#for block in snake_body:
		#$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(3,0), 0)
	for block_index in snake_body.size():
		var block = snake_body[block_index]
		
		#head
		if block_index == 0:
			var head_dir = relation2(snake_body[0], snake_body[1])
			if head_dir == 'right': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["head-move-right"], Vector2i(0,0), 0)
				previous_direction = "right"
			elif head_dir == 'left': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["head-move-left"], Vector2i(0,0), 0)
				previous_direction = "left"
			elif head_dir == 'up': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["head-move-up"], Vector2i(0,0), 0)
				previous_direction = "up"
			elif head_dir == 'down': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["head-move-down"], Vector2i(0,0), 0)
				previous_direction = "down"
			
		#head -> body
		elif block_index == 1:
			var head_dir = relation2(snake_body[0], snake_body[1])
			#turning has occurred
			var previous_block = snake_body[block_index + 1] - block
			var next_block = snake_body[block_index - 1] - block
			if previous_block.x == -1 and next_block.y == -1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["nw-turn-up"], Vector2i(0,0), 0)
			elif next_block.x == -1 and previous_block.y == -1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["nw-turn-left"], Vector2i(0,0), 0)
			elif previous_block.x == -1 and next_block.y == 1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["sw-turn-down"], Vector2i(0,0), 0)
			elif next_block.x == -1 and previous_block.y == 1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["sw-turn-left"], Vector2i(0,0), 0)
			elif previous_block.x == 1 and next_block.y == -1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["ne-turn-up"], Vector2i(0,0), 0)
			elif next_block.x == 1 and previous_block.y == -1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["ne-turn-right"], Vector2i(0,0), 0)
			elif previous_block.x == 1 and next_block.y == 1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["se-turn-down"], Vector2i(0,0), 0)
			elif next_block.x == 1 and previous_block.y == 1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["se-turn-right"], Vector2i(0,0), 0)
			#no turning has occured
			elif head_dir == 'right': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["head-exit-right"], Vector2i(0,0), 0)
			elif head_dir == 'left': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["head-exit-left"], Vector2i(0,0), 0)
			elif head_dir == 'up': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["head-exit-up"], Vector2i(0,0), 0)
			elif head_dir == 'down': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["head-exit-down"], Vector2i(0,0), 0)
	#body -> tail
		elif block_index == snake_body.size()-2:
			var tail_dir = relation2(snake_body[-1], snake_body[-2])
			#tail_dir = which direction the end tail points to
			var previous_block = snake_body[block_index + 1] - block
			var next_block = snake_body[block_index - 1] - block
			if previous_block.x == -1 and next_block.y == -1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["nw-move-up"], Vector2i(0,0), 0)
			elif next_block.x == -1 and previous_block.y == -1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["nw-move-left"], Vector2i(0,0), 0)
			elif previous_block.x == -1 and next_block.y == 1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["sw-move-down"], Vector2i(0,0), 0)
			elif next_block.x == -1 and previous_block.y == 1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["sw-move-left"], Vector2i(0,0), 0)
			elif previous_block.x == 1 and next_block.y == -1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["ne-move-up"], Vector2i(0,0), 0)
			elif next_block.x == 1 and previous_block.y == -1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["ne-move-right"], Vector2i(0,0), 0)
			elif previous_block.x == 1 and next_block.y == 1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["se-move-down"], Vector2i(0,0), 0)
			elif next_block.x == 1 and previous_block.y == 1:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["se-move-right"], Vector2i(0,0), 0)
			#no turning has occured
			elif tail_dir == 'right': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["body-move-left"], Vector2i(0,0), 0)
			elif tail_dir == 'left': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["body-move-right"], Vector2i(0,0), 0)
			elif tail_dir == 'up': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["body-move-down"], Vector2i(0,0), 0)
			elif tail_dir == 'down': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["body-move-up"], Vector2i(0,0), 0)
		
		#tail
		elif block_index == snake_body.size()-1:
			var tail_dir = relation2(snake_body[-1], snake_body[-2])
			#tail_dir = which direction the end tail points to
			if tail_dir == 'right': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["tail-move-left"], Vector2i(0,0), 0)
			elif tail_dir == 'left': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["tail-move-right"], Vector2i(0,0), 0)
			elif tail_dir == 'up': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["tail-move-down"], Vector2i(0,0), 0)
			elif tail_dir == 'down': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["tail-move-up"], Vector2i(0,0), 0)
		else:
			var previous_block = snake_body[block_index + 1] - block
			var next_block = snake_body[block_index - 1] - block
			#going vertical
			if previous_block.x == next_block.x:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["body-vertical"], Vector2i(0,0), 0)
			#going horizontal
			elif previous_block.y == next_block.y:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["body-horizontal"], Vector2i(0,0), 0) 
			else:
				
				if previous_block.x == -1 and next_block.y == -1 or next_block.x == -1 and previous_block.y == -1:
					$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["body-nw"], Vector2i(0,0), 0)	
				
				elif previous_block.x == -1 and next_block.y == 1 or next_block.x == -1 and previous_block.y == 1:
					$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["body-sw"], Vector2i(0,0), 0)		
				
				elif previous_block.x == 1 and next_block.y == -1 or next_block.x == 1 and previous_block.y == -1:
					$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["body-ne"], Vector2i(0,0), 0)	
				
				elif previous_block.x == 1 and next_block.y == 1 or next_block.x == 1 and previous_block.y == 1:
					$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE_PARTS["body-se"], Vector2i(0,0), 0)	
	
func relation2(first_block: Vector2, second_block: Vector2):
	var block_relation = second_block - first_block
	if block_relation == Vector2(-1,0): return 'right'
	elif block_relation == Vector2(1,0): return 'left'
	elif block_relation == Vector2(0,1): return 'up'
	elif block_relation == Vector2(0,-1): return 'down'

func move_snake():
	if add_apples:
		for tiles in SNAKE_PARTS:
			delete_tiles(SNAKE_PARTS[tiles])
		# take everything except the last index in the body (tail)
		var body_copy = snake_body.slice(0,snake_body.size())
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0, new_head)
		snake_body = body_copy
		add_apples = false
	else:
		for tiles in SNAKE_PARTS:
			delete_tiles(SNAKE_PARTS[tiles])
		# take everything except the last index in the body (tail)
		var body_copy = snake_body.slice(0,snake_body.size()-1)
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0, new_head)
		snake_body = body_copy

func delete_tiles(id: int):
	var cells = $SnakeApple.get_used_cells_by_id(0, id)
	# -1 id is to delete the cell
	for cell in cells:
		$SnakeApple.set_cell(0, Vector2i(cell.x,cell.y), -1)

func _input(event):
	if Input.is_action_just_pressed("ui_up") and previous_direction != "down":
		snake_direction = Vector2(0, -1)
	elif Input.is_action_just_pressed("ui_down") and previous_direction != "up":
		snake_direction = Vector2(0, 1)
	elif Input.is_action_just_pressed("ui_left") and previous_direction != "right":
		snake_direction = Vector2(-1, 0)
	elif Input.is_action_just_pressed("ui_right") and previous_direction != "left":
		snake_direction = Vector2(1, 0)
	

func _ready():
	apple_pos = place_apple()
		#$SnakeApple.set_cell(0,Vector2i(0,0),1,Vector2i(4,0),0)
	
func place_apple():
	randomize()
	var x = randi() % 24
	var y = randi() % 24
	return Vector2(x,y)
	
func draw_apple():
	$SnakeApple.set_cell(0, Vector2i(apple_pos.x, apple_pos.y), APPLE, Vector2i(4,1),0)
	
func check_snake_out_of_map():
	var head = snake_body[0]
	if head.x > 24:
		for i in range(snake_body.size()-1):
			snake_body[i].x = -i
	elif head.x < 0:
		for i in range(snake_body.size()-1):
			snake_body[i].x = 24+i
	elif head.y > 24:
		for i in range(snake_body.size()-1):
			snake_body[i].y = -i
	elif head.y < 0:
		for i in range(snake_body.size()-1):
			snake_body[i].y = 24+i

func check_apple_eaten():
	if apple_pos == snake_body[0]:
		apple_pos = place_apple()
		add_apples = true
		get_tree().call_group('ScoreGroup', 'update_score', snake_body.size())

func _on_snake_tick_timeout():
	move_snake()
	draw_snake()
	draw_apple()
	check_apple_eaten()
	check_snake_out_of_map()
