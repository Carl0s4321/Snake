extends Node


var apple_pos
var add_apples = false
const APPLE = 1

const SNAKE = 2

const ENEMY_BASIC = 3
const ENEMY_HUNTER = 4

const DEAD = 0
const ALIVE = 1
const DYING = 2

const TILE_PARTS = {
	"apple":0,
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

var player_snake = {
	"status":ALIVE,
	"type":SNAKE,
	"basic_turn":randi_range(1,10),
	"direction":Vector2(1,0),
	"body":[Vector2(5,10),Vector2(4,10),Vector2(3,10),Vector2(2,10)]
}
var previous_direction = "right"

var enemy_snakes = [
	{
		"status":ALIVE,
		"type":ENEMY_BASIC,
		"basic_turn":randi_range(1,10),
		"direction":Vector2(-1,0),
	 	"body":[Vector2(17,5),Vector2(18,5),Vector2(19,5),Vector2(20,5),Vector2(21,5),Vector2(22,5)]
		
	},
	{
		"status":ALIVE,
		"type":ENEMY_HUNTER,
		"basic_turn":randi_range(1,10),
		"direction":Vector2(-1,0),
	 	"body":[Vector2(17,10),Vector2(18,10),Vector2(19,10),Vector2(20,10),Vector2(21,10),Vector2(22,10)]
		#"direction":Vector2(0,1),
		
	 	#"body":[Vector2(5,5),Vector2(5,4),Vector2(5,3),Vector2(5,2)]
	}
	]
	
	
func draw_still_snake(layer, snake):
	for block_index in snake["body"].size():
		var block = snake["body"][block_index]
		
		#head
		if block_index == 0:
			var head_dir = relation2(snake["body"][0], snake["body"][1])
			if head_dir == 'right': 
				set_snake(block, layer, "head-right")
			elif head_dir == 'left': 
				set_snake(block, layer, "head-left")
			elif head_dir == 'up': 
				set_snake(block, layer, "head-up")
			elif head_dir == 'down': 
				set_snake(block, layer, "head-down")
		#tail
		elif block_index == snake["body"].size()-1:
			var tail_dir = relation2(snake["body"][-1], snake["body"][-2])
			#tail_dir = which direction the end tail points to
			if tail_dir == 'right': 
				set_snake(block, layer, "tail-right")
			elif tail_dir == 'left': 
				set_snake(block, layer, "tail-left")
			elif tail_dir == 'up': 
				set_snake(block, layer, "tail-up")
			elif tail_dir == 'down': 
				set_snake(block, layer, "tail-down")
		else:
			var previous_block = snake["body"][block_index + 1] - block
			var next_block = snake["body"][block_index - 1] - block
			#going vertical
			if previous_block.x == next_block.x:
				set_snake(block, layer, "body-vertical")
			#going horizontal
			elif previous_block.y == next_block.y:
				set_snake(block, layer, "body-horizontal") 
			else:
				var compress = previous_block + next_block
				if compress.x == -1 and compress.y == -1:
					set_snake(block, layer, "body-nw")
				elif compress.x == -1 and compress.y == 1:
					set_snake(block, layer, "body-sw")
				elif compress.x == 1 and compress.y == -1:
					set_snake(block, layer, "body-ne")
				elif compress.x == 1 and compress.y == 1:
					set_snake(block, layer, "body-se")
				#screen wrap
				elif compress.x == -1 and compress.y == 24 or compress.x == 24 and compress.y == -1:
					set_snake(block, layer, "body-nw")
				elif compress.x == -1 and compress.y == -24 or compress.x == 24 and compress.y == 1:
					set_snake(block, layer, "body-sw")
				elif compress.x == 1 and compress.y == 24 or compress.x == -24 and compress.y == -1:
					set_snake(block, layer, "body-ne")
				elif compress.x == 1 and compress.y == -24 or compress.x == -24 and compress.y == 1:
					set_snake(block, layer, "body-se")
func draw_snake(layer, snake):
	if snake["status"] == DEAD: return
	if snake["status"] == DYING:
		#draw still parts
		draw_still_snake(layer, snake)
		snake["status"] = DEAD
	#for block in snake_body:
		#$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(0,0), 0)
	for block_index in snake["body"].size():
		var block = snake["body"][block_index]
		
		#head
		if block_index == 0:
			var head_dir = relation2(snake["body"][0], snake["body"][1])
			var direction = "none"
			if head_dir == 'right': 
				set_snake(block, layer, "head-move-right")
				direction = "right"
			elif head_dir == 'left': 
				set_snake(block, layer, "head-move-left")
				direction = "left"
			elif head_dir == 'up': 
				set_snake(block, layer, "head-move-up")
				direction = "up"
			elif head_dir == 'down': 
				set_snake(block, layer, "head-move-down")
				direction = "down"
			
			if direction != "none" and layer == SNAKE:
				previous_direction = direction
		#head -> body
		elif block_index == 1:
			var head_dir = relation2(snake["body"][0], snake["body"][1])
			#turning has occurred
			var previous_block = snake["body"][block_index + 1] - block
			var next_block = snake["body"][block_index - 1] - block
			var compress = previous_block + next_block
			
			if previous_block.x == -1 and next_block.y == -1:
				set_snake(block, layer, "nw-turn-up")
			elif next_block.x == -1 and previous_block.y == -1:
				set_snake(block, layer, "nw-turn-left")
			elif previous_block.x == -1 and next_block.y == 1:
				set_snake(block, layer, "sw-turn-down")
			elif next_block.x == -1 and previous_block.y == 1:
				set_snake(block, layer, "sw-turn-left")
			elif previous_block.x == 1 and next_block.y == -1:
				set_snake(block, layer, "ne-turn-up")
			elif next_block.x == 1 and previous_block.y == -1:
				set_snake(block, layer, "ne-turn-right")
			elif previous_block.x == 1 and next_block.y == 1:
				set_snake(block, layer, "se-turn-down")
			elif next_block.x == 1 and previous_block.y == 1:
				set_snake(block, layer, "se-turn-right")
			#screen wrap turning (also impossible for next_block to have 24 as any value)
			elif compress.x == 24 and compress.y == -1:
				set_snake(block, layer, "nw-turn-up")#yes
			elif compress.x == -1 and compress.y == 24:
				set_snake(block, layer, "nw-turn-left")#yes
			elif compress.x == 24 and compress.y == 1:
				set_snake(block, layer, "sw-turn-down")#yes
			elif compress.x == -1 and compress.y == -24:
				set_snake(block, layer, "sw-turn-left")#yes
			elif compress.x == -24 and compress.y == -1:
				set_snake(block, layer, "ne-turn-up")#yes
			elif compress.x == 1 and compress.y == 24:
				set_snake(block, layer, "ne-turn-right")#yes
			elif compress.x == -24 and compress.y == 1:
				set_snake(block, layer, "se-turn-down") #yes
			elif compress.x == 1 and compress.y == -24:
				set_snake(block, layer, "se-turn-right")#yes
			
			#no turning has occured
			elif head_dir == 'right': 
				set_snake(block, layer, "head-exit-right")
			elif head_dir == 'left': 
				set_snake(block, layer, "head-exit-left")
			elif head_dir == 'up': 
				set_snake(block, layer, "head-exit-up")
			elif head_dir == 'down': 
				set_snake(block, layer, "head-exit-down")
	#body -> tail
		elif block_index == snake["body"].size()-2:
			var tail_dir = relation2(snake["body"][-1], snake["body"][-2])
			#tail_dir = which direction the end tail points to
			var previous_block = snake["body"][block_index + 1] - block
			var next_block = snake["body"][block_index - 1] - block
			var compress = previous_block + next_block
			#order matters
			if previous_block.x == -1 and next_block.y == -1:
				set_snake(block, layer, "nw-move-up")
			elif next_block.x == -1 and previous_block.y == -1:
				set_snake(block, layer, "nw-move-left")
			elif previous_block.x == -1 and next_block.y == 1:
				set_snake(block, layer, "sw-move-down")
			elif next_block.x == -1 and previous_block.y == 1:
				set_snake(block, layer, "sw-move-left")
			elif previous_block.x == 1 and next_block.y == -1:
				set_snake(block, layer, "ne-move-up")
			elif next_block.x == 1 and previous_block.y == -1:
				set_snake(block, layer, "ne-move-right")
			elif previous_block.x == 1 and next_block.y == 1:
				set_snake(block, layer, "se-move-down")
			elif next_block.x == 1 and previous_block.y == 1:
				set_snake(block, layer, "se-move-right")
				
			#screen wrap turning (also impossible for next_block to have 24 as any value)
			elif (next_block.x == 24 and previous_block.y == -1) or (next_block.x == -1 and previous_block.y == 24):
				set_snake(block, layer, "nw-move-left")#yes
			elif (previous_block.x == -1 and next_block.y == 24) or (previous_block.x == 24 and next_block.y == -1):
				set_snake(block, layer, "nw-move-up")#yes
			elif (next_block.x == 24 and previous_block.y == 1) or (next_block.x == -1 and previous_block.y == -24):
				set_snake(block, layer, "sw-move-left")#yes
			elif (previous_block.x == -1 and next_block.y == -24) or (previous_block.x == 24 and next_block.y == 1):
				set_snake(block, layer, "sw-move-down")#yes
			elif (next_block.x == -24 and previous_block.y == -1) or (next_block.x == 1 and previous_block.y == 24):
				set_snake(block, layer, "ne-move-right")#yes
			elif (previous_block.x == 1 and next_block.y == 24) or (previous_block.x == -24 and next_block.y == -1):
				set_snake(block, layer, "ne-move-up")#yes
			elif (next_block.x == -24 and previous_block.y == 1) or (next_block.x == 1 and previous_block.y == -24):
				set_snake(block, layer, "se-move-right") #yes
			elif (previous_block.x == 1 and next_block.y == -24) or (previous_block.x == -24 and next_block.y == 1):
				set_snake(block, layer, "se-move-down")#yes
				
			#no turning has occured
			elif tail_dir == 'right': 
				set_snake(block, layer, "body-move-left")
			elif tail_dir == 'left': 
				set_snake(block, layer, "body-move-right")
			elif tail_dir == 'up': 
				set_snake(block, layer, "body-move-down")
			elif tail_dir == 'down': 
				set_snake(block, layer, "body-move-up")
		#tail
		elif block_index == snake["body"].size()-1:
			var tail_dir = relation2(snake["body"][-1], snake["body"][-2])
			#tail_dir = which direction the end tail points to
			if tail_dir == 'right': 
				set_snake(block, layer, "tail-move-right")
			elif tail_dir == 'left': 
				set_snake(block, layer, "tail-move-left")
			elif tail_dir == 'up': 
				set_snake(block, layer, "tail-move-up")
			elif tail_dir == 'down': 
				set_snake(block, layer, "tail-move-down")
		else:
			var previous_block = snake["body"][block_index + 1] - block
			var next_block = snake["body"][block_index - 1] - block
			#going vertical
			if previous_block.x == next_block.x:
				set_snake(block, layer, "body-vertical")
			#going horizontal
			elif previous_block.y == next_block.y:
				set_snake(block, layer, "body-horizontal") 
			else:
				var compress = previous_block + next_block
				if compress.x == -1 and compress.y == -1:
					set_snake(block, layer, "body-nw")
				elif compress.x == -1 and compress.y == 1:
					set_snake(block, layer, "body-sw")
				elif compress.x == 1 and compress.y == -1:
					set_snake(block, layer, "body-ne")
				elif compress.x == 1 and compress.y == 1:
					set_snake(block, layer, "body-se")
				#screen wrapping
				#nw (-1,24) (24,-1) (24,-1) (-1,24)
				elif compress.x == -1 and compress.y == 24 or compress.x == 24 and compress.y == -1:
					set_snake(block, layer, "body-nw")
				elif compress.x == -1 and compress.y == -24 or compress.x == 24 and compress.y == 1:
					set_snake(block, layer, "body-sw")
				elif compress.x == 1 and compress.y == 24 or compress.x == -24 and compress.y == -1:
					set_snake(block, layer, "body-ne")
				elif compress.x == 1 and compress.y == -24 or compress.x == -24 and compress.y == 1:
					set_snake(block, layer, "body-se")
func set_snake_int(block, layer, part_type : int):
	#if it would place it out of bounds, wrap it
	var x = wrapi(block.x, 0 ,25)
	var y = wrapi(block.y, 0 ,25)
	$SnakeApple.set_cell(layer, Vector2i(x, y), part_type, Vector2i(0,0), 0)
func set_snake(block, layer, part_name : String):
	set_snake_int(block, layer, TILE_PARTS[part_name])
	
func relation2(first_block: Vector2, second_block: Vector2):
	var block_relation = second_block - first_block
	if block_relation == Vector2(-1,0): return 'right'
	elif block_relation == Vector2(1,0): return 'left'
	elif block_relation == Vector2(0,1): return 'up'
	elif block_relation == Vector2(0,-1): return 'down'
	#screen wrap
	elif block_relation == Vector2(-24,0): return 'left'
	elif block_relation == Vector2(24,0): return 'right'
	elif block_relation == Vector2(0,24): return 'down'
	elif block_relation == Vector2(0,-24): return 'up'

func move_snake(layer, snake):
	if snake["status"] == DEAD: return
	delete_tiles(snake["body"][-1], layer) #delete the tail
	
	var body_copy
	if add_apples and layer == SNAKE: #if player
		body_copy = snake["body"].slice(0,snake["body"].size())
		add_apples = false
	else:
		# take everything except the last index in the body (tail)
		body_copy = snake["body"].slice(0,snake["body"].size()-1)
	
	var new_head = body_copy[0] + snake["direction"]
	#detect collisions
	var id = check_collision(new_head)
	if id != -1:#not empty space
		#if collision, attempt to move away
		if snake["type"] != SNAKE:
			var attempts = 1
			while id != -1 and attempts > 0:
				snake["direction"] = choose_direction([snake["direction"] * -1])
				new_head = body_copy[0] + snake["direction"]
				id = check_collision(new_head)
				attempts -= 1
			if id != -1:
				kill_snake(layer, snake, body_copy)
		else: #otherwise kill
			kill_snake(layer, snake, body_copy)
			return
	
	
	body_copy.insert(0, new_head)
	snake["body"] = body_copy

func basic_enemy_movement(snake):
	if snake["basic_turn"] <= 0:
		snake["direction"] = choose_direction([snake["direction"] * -1])
		snake["basic_turn"] = randi_range(0,10)
	else:
		snake["basic_turn"] -= 1
func hunting_enemy_movement(snake):
	var difference = (player_snake["body"][0]+(player_snake["direction"])) - snake["body"][0]
	if abs(difference.x) > abs(difference.y):
		snake["direction"] = Vector2(signi(difference.x), 0)
	elif abs(difference.y) > abs(difference.x):
		snake["direction"] = Vector2(0, signi(difference.y))
	else:
		var list = [Vector2(signi(difference.x), 0), Vector2(0, signi(difference.y))]
		var vector = list[randi_range(0,1)]
		snake["direction"] = vector
	
	#check if the future position will collide
	var banned = [snake["direction"], snake["direction"]*-1]
	var attempts = 3
	while (check_collision(snake["body"][0] + snake["direction"]) != -1) and attempts > 0:
		snake["direction"] = choose_direction(banned)
		banned.append(snake["direction"])
		attempts -= 1

var possible_directions = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]
func choose_direction(banned_directions : Array):
	var direction = possible_directions[randi_range(0,3)]
	var attempts = 10
	while banned_directions.has(direction) and attempts > 0: #find a direction that is not banned
		direction = possible_directions[randi_range(0,3)]
		attempts -= 1
	return direction

func kill_snake(layer, snake, body_copy):
	snake["body"] = body_copy
	draw_still_snake(layer, snake)
	snake["status"] = DEAD

func delete_tiles(position, layer):
	$SnakeApple.set_cell(layer, position, -1)
		
var collision_layers = [SNAKE, ENEMY_BASIC, ENEMY_HUNTER]
#return true if collision happens
func check_collision(position):
	for i in collision_layers:
		var id = $SnakeApple.get_cell_source_id(i, position)
		if id != -1:
			return id
	return -1

var recently_pressed = 0
func _input(event):
	#smoother movement
	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
		recently_pressed = 1
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		recently_pressed = -1
	if Input.is_action_just_released("ui_down") or Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		recently_pressed = 0
		
	var vertical = int(signf(Input.get_axis("ui_down","ui_up")))
	var horizontal = int(signf(Input.get_axis("ui_left","ui_right")))
	if recently_pressed == 1:
		if vertical == 1 and previous_direction != "down":
			player_snake["direction"] = Vector2(0, -1)
		if vertical == -1 and previous_direction != "up":
			player_snake["direction"] = Vector2(0, 1)
	elif recently_pressed == -1:
		if horizontal == -1 and previous_direction != "right":
			player_snake["direction"] = Vector2(-1, 0)
		if horizontal == 1 and previous_direction != "left":
			player_snake["direction"] = Vector2(1, 0)
	else:
		if vertical == 1 and previous_direction != "down":
			player_snake["direction"] = Vector2(0, -1)
		if vertical == -1 and previous_direction != "up":
			player_snake["direction"] = Vector2(0, 1)
		if horizontal == -1 and previous_direction != "right":
			player_snake["direction"] = Vector2(-1, 0)
		if horizontal == 1 and previous_direction != "left":
			player_snake["direction"] = Vector2(1, 0)
	

func _ready():
	apple_pos = place_apple()
		#$SnakeApple.set_cell(0,Vector2i(0,0),1,Vector2i(0,0),0)
	
func place_apple():
	randomize()
	var x = randi() % 24
	var y = randi() % 24
	return Vector2(x,y)
	
func draw_apple():
	$SnakeApple.set_cell(APPLE, Vector2i(apple_pos.x, apple_pos.y), 0, Vector2i(0,0),0)
	
func check_snake_out_of_map(snake):
	var head = snake["body"][0]
	
	if head.x > 24:
		#for i in range(snake["body"].size()-1):
		#delete_tiles(snake["body"][0], snake["type"])
		snake["body"][0].x = 0
	elif head.x < 0:
		#delete_tiles(snake["body"][0], snake["type"])
		#for i in range(snake["body"].size()-1):
		snake["body"][0].x = 24
	elif head.y > 24:
		#delete_tiles(snake["body"][0], snake["type"])
		#for i in range(snake["body"].size()-1):
		snake["body"][0].y = 0
	elif head.y < 0:
		#delete_tiles(snake["body"][0], snake["type"])
		#for i in range(snake["body"].size()-1):
		snake["body"][0].y = 24

func check_apple_eaten():
	if apple_pos == player_snake["body"][1]:
		var tile = $SnakeApple.get_cell_source_id(SNAKE, player_snake["body"][-1])
		if(tile == 50 or tile == 51): tile = 7
		if(tile == 49 or tile == 52): tile = 12
		set_snake_int(player_snake["body"][-2], SNAKE, tile)
		set_snake_int(player_snake["body"][-1], SNAKE, $SnakeApple.get_cell_source_id(SNAKE, player_snake["body"][-1])-31)
		delete_tiles(apple_pos, APPLE)
		apple_pos = place_apple()
		add_apples = true
		get_tree().call_group('ScoreGroup', 'update_score', player_snake["body"].size())

func _on_snake_tick_timeout():

	#player
	move_snake(SNAKE, player_snake)
	draw_snake(SNAKE, player_snake)
	draw_apple()
	check_apple_eaten()
	check_snake_out_of_map(player_snake)
	#enemies
	for enemy in enemy_snakes:
		var type = enemy["type"]
		if(type == ENEMY_BASIC):
			basic_enemy_movement(enemy)
		elif(type == ENEMY_HUNTER):
			hunting_enemy_movement(enemy)
		move_snake(type, enemy)
		draw_snake(type, enemy)
		check_snake_out_of_map(enemy)
