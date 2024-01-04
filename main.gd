extends Node2D

const SNAKE = 1

var snake_body = [Vector2(5,10),Vector2(4,10),Vector2(3,10)]
var snake_direction  = Vector2(1,0)

func draw_snake():
	#for block in snake_body:
		#$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(3,0), 0)
	for block_index in snake_body.size():
		var block = snake_body[block_index]
		
		#head
		if block_index == 0:
			var head_dir = relation2(snake_body[0], snake_body[1])
			if head_dir == 'right': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(4,0), 0)
			if head_dir == 'left': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(3,1), 0)
			if head_dir == 'up': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(6,1), 0)
			if head_dir == 'down': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(7,2), 0)
		
		#tail
		elif block_index == snake_body.size()-1:
			var tail_dir = relation2(snake_body[-1], snake_body[-2])
			#tail_dir = which direction the end tail points to
			if tail_dir == 'right': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(5,1), 0)
			if tail_dir == 'left': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(2,0), 0)
			if tail_dir == 'up': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(7,0), 0)
			if tail_dir == 'down': 
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(6,3), 0)
		else:
			var previous_block = snake_body[block_index + 1] - block
			var next_block = snake_body[block_index - 1] - block
			#going vertical
			if previous_block.x == next_block.x:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(6,2), 0)
			#going horizontal
			elif previous_block.y == next_block.y:
				$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(3,0), 0) 
			else:
				
				if previous_block.x == -1 and next_block.y == -1 or next_block.x == -1 and previous_block.y == -1:
					$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(1,1), 0)	
				
				if previous_block.x == -1 and next_block.y == 1 or next_block.x == -1 and previous_block.y == 1:
					$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(1,0), 0)		
				
				if previous_block.x == 1 and next_block.y == -1 or next_block.x == 1 and previous_block.y == -1:
					$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(0,1), 0)	
				
				if previous_block.x == 1 and next_block.y == 1 or next_block.x == 1 and previous_block.y == 1:
					$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(0,0), 0)	
	
func relation2(first_block: Vector2, second_block: Vector2):
	var block_relation = second_block - first_block
	if block_relation == Vector2(-1,0): return 'right'
	if block_relation == Vector2(1,0): return 'left'
	if block_relation == Vector2(0,1): return 'up'
	if block_relation == Vector2(0,-1): return 'down'

func move_snake():
	delete_tiles(SNAKE)
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
	if Input.is_action_just_pressed("ui_up"):
		snake_direction = Vector2(0, -1)
	if Input.is_action_just_pressed("ui_left"):
		snake_direction = Vector2(-1, 0)
	if Input.is_action_just_pressed("ui_right"):
		snake_direction = Vector2(1, 0)
	if Input.is_action_just_pressed("ui_down"):
		snake_direction = Vector2(0, 1)

func _ready():
	pass
	#$SnakeApple.set_cell(0,Vector2i(0,0),1,Vector2i(4,0),0)
	

func _on_snake_tick_timeout():
	move_snake()
	draw_snake()
