extends Node

@export var floating_text : PackedScene
@export var tile_piece : PackedScene
@export var one_shot : PackedScene

signal game_over

var tile_positions = {}
var apple_positions = []

var timer = 0
const FOOD = 1
var score = 0

const SNAKE = 2

const ENEMY_BASIC = 3
const ENEMY_HUNTER = 4
const ENEMY_LONG = 5

const DEAD = 0
const ALIVE = 1
const DYING = 2
const SPAWNING = 3
const SPAWNED = 4

const TILE_PARTS = {
	"apple":0,
	"meat":2,
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
	"spawn_count":0,
	"basic_turn":randi_range(1,10),
	"direction":Vector2(1,0),
	"grow":false,
	"body":[Vector2(3,10),Vector2(2,10),Vector2(1,10),Vector2(0,10)]
}
var previous_direction = "right"

var enemy_snakes = [
	{
		"status":SPAWNING,
		"spawn_count":8,
		"type":ENEMY_BASIC,
		"basic_turn":randi_range(20,20),
		"rerouting":1,
		"direction":Vector2(-1,0),
		"grow":false,
	 	"body":[Vector2(25,15),Vector2(25,15),Vector2(25,15),Vector2(25,15),Vector2(25,15),Vector2(25,15),Vector2(25,15),Vector2(25,15)]
	},{
		"status":SPAWNING,
		"spawn_count":8,
		"type":ENEMY_BASIC,
		"basic_turn":randi_range(1,10),
		"rerouting":1,
		"direction":Vector2(-1,0),
		"grow":false,
	 	"body":[Vector2(25,5),Vector2(25,5),Vector2(25,5),Vector2(25,5),Vector2(25,15),Vector2(25,15),Vector2(25,15),Vector2(25,15)]
	},
	]

var enemy_template = {
	"status":SPAWNING,
	"type":ENEMY_BASIC,
	"spawn_count":0,
	"basic_turn":randi_range(5,10),
	"rerouting":1,
	"direction":Vector2(0,0),
	"grow":false,
	"body":[]
}
func spawn_snake():
	var attempts = 10
	var is_horizontal = randi_range(0,1)
	var is_negative = (randi_range(0,1) * 2)-1
	var spawn_position
	var spawn_range 
	var spawn_direction
	var colliding = -1
	while colliding != null and attempts > 0:
		is_horizontal = randi_range(0,1)
		is_negative = (randi_range(0,1) * 2)-1
		if is_horizontal == 1:
			spawn_position = Vector2(1,0)
			spawn_direction = Vector2(1,0) * is_negative * -1
			spawn_range = Vector2(0, randi_range(0,24))
		else:
			spawn_position = Vector2(0,1)
			spawn_direction = Vector2(0,1) * is_negative * -1
			spawn_range = Vector2(randi_range(0,24), 0)
			
		spawn_position = ((spawn_position*12) + (is_negative*spawn_position*13)) + spawn_range
		attempts -= 1
		colliding = check_collision(spawn_position + spawn_direction) #null means no collision
	if attempts == 0: return
	
	var enemy_properties = enemy_template.duplicate(true)
	var enemy_type = randi_range(3,5)
	var enemy_length = randi_range(4,12)
	
	if enemy_type == ENEMY_LONG:
		enemy_properties["basic_turn"] = randi_range(10,15)
		enemy_properties["rerouting"] = 10
		enemy_length = randi_range(20,40)
	
	enemy_properties["spawn_count"] = enemy_length+1
	enemy_properties["direction"] = spawn_direction
	enemy_properties["type"] = enemy_type
	for i in enemy_length:
		enemy_properties["body"].push_back(spawn_position)
	
	enemy_snakes.push_back(enemy_properties)

func check_spawn(snake):
	var wrapping = true
	if snake["spawn_count"] > 0: 
		wrapping = false
		var tail = snake["body"][-1]
		if tail == null: return
		if tail.x >= 0 and tail.x <= 24 and tail.y >= 0 and tail.y <= 24:
			snake["status"] = ALIVE
			wrapping = true
	snake["spawn_count"] -= 1
	return wrapping
func draw_still_snake(layer, snake):
	
	var wrapping = check_spawn(snake)
	
	for block_index in snake["body"].size():
		var block = snake["body"][block_index]
		
		#head
		if block_index == 0:
			var head_dir = relation2(snake["body"][0], snake["body"][1])
			if head_dir == null: return
			
			if snake["direction"] == Vector2(1,0) and head_dir == "down":
				set_snake(block, layer, "bonk-ne-right", wrapping)
			elif snake["direction"] == Vector2(1,0) and head_dir == "up":
				set_snake(block, layer, "bonk-se-right", wrapping)
			elif snake["direction"] == Vector2(-1,0) and head_dir == "down":
				set_snake(block, layer, "bonk-nw-left", wrapping)
			elif snake["direction"] == Vector2(-1,0) and head_dir == "up":
				set_snake(block, layer, "bonk-sw-left", wrapping)
			elif snake["direction"] == Vector2(0,1) and head_dir == "right":
				set_snake(block, layer, "bonk-sw-down", wrapping)
			elif snake["direction"] == Vector2(0,1) and head_dir == "left":
				set_snake(block, layer, "bonk-se-down", wrapping)
			elif snake["direction"] == Vector2(0,-1) and head_dir == "right":
				set_snake(block, layer, "bonk-nw-up", wrapping)
			elif snake["direction"] == Vector2(0,-1) and head_dir == "left":
				set_snake(block, layer, "bonk-ne-up", wrapping)
				
			elif head_dir == 'right': 
				set_snake(block, layer, "bonk-right", wrapping)
			elif head_dir == 'left': 
				set_snake(block, layer, "bonk-left", wrapping)
			elif head_dir == 'up': 
				set_snake(block, layer, "bonk-up", wrapping)
			elif head_dir == 'down': 
				set_snake(block, layer, "bonk-down", wrapping)
		#tail
		elif block_index == snake["body"].size()-1:
			var tail_dir = relation2(snake["body"][-1], snake["body"][-2])
			if tail_dir == null: return
			
			#tail_dir = which direction the end tail points to
			if tail_dir == 'right': 
				set_snake(block, layer, "tail-right", wrapping)
			elif tail_dir == 'left': 
				set_snake(block, layer, "tail-left", wrapping)
			elif tail_dir == 'up': 
				set_snake(block, layer, "tail-up", wrapping)
			elif tail_dir == 'down': 
				set_snake(block, layer, "tail-down", wrapping)
		else:
			var previous_block = snake["body"][block_index + 1] - block
			var next_block = snake["body"][block_index - 1] - block
			#going vertical
			if previous_block.x == next_block.x:
				set_snake(block, layer, "body-vertical", wrapping)
			#going horizontal
			elif previous_block.y == next_block.y:
				set_snake(block, layer, "body-horizontal", wrapping) 
			else:
				var compress = previous_block + next_block
				if compress.x == -1 and compress.y == -1:
					set_snake(block, layer, "body-nw", wrapping)
				elif compress.x == -1 and compress.y == 1:
					set_snake(block, layer, "body-sw", wrapping)
				elif compress.x == 1 and compress.y == -1:
					set_snake(block, layer, "body-ne", wrapping)
				elif compress.x == 1 and compress.y == 1:
					set_snake(block, layer, "body-se", wrapping)
				#screen wrap
				elif compress.x == -1 and compress.y == 24 or compress.x == 24 and compress.y == -1:
					set_snake(block, layer, "body-nw", wrapping)
				elif compress.x == -1 and compress.y == -24 or compress.x == 24 and compress.y == 1:
					set_snake(block, layer, "body-sw", wrapping)
				elif compress.x == 1 and compress.y == 24 or compress.x == -24 and compress.y == -1:
					set_snake(block, layer, "body-ne", wrapping)
				elif compress.x == 1 and compress.y == -24 or compress.x == -24 and compress.y == 1:
					set_snake(block, layer, "body-se", wrapping)
func draw_snake(layer, snake):
	if snake["status"] == DEAD: return
	if snake["status"] == DYING:
		#draw still parts
		draw_still_snake(layer, snake)
		snake["status"] = DEAD
		return
	#for block in snake_body:
		#$SnakeApple.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(0,0), 0)
	var wrapping = check_spawn(snake)
	
	for block_index in snake["body"].size():
		var block = snake["body"][block_index]
		
		#head
		if block_index == 0:
			var head_dir = relation2(snake["body"][0], snake["body"][1])
			if head_dir == null: return
			var direction = "none"
			if head_dir == 'right': 
				set_snake(block, layer, "head-move-right", wrapping)
				direction = "right"
			elif head_dir == 'left': 
				set_snake(block, layer, "head-move-left", wrapping)
				direction = "left"
			elif head_dir == 'up': 
				set_snake(block, layer, "head-move-up", wrapping)
				direction = "up"
			elif head_dir == 'down': 
				set_snake(block, layer, "head-move-down", wrapping)
				direction = "down"
			
			if direction != "none" and layer == SNAKE:
				previous_direction = direction
		#head -> body
		elif block_index == 1:
			var head_dir = relation2(snake["body"][0], snake["body"][1])
			if head_dir == null: return
			#turning has occurred
			var previous_block = snake["body"][block_index + 1] - block
			var next_block = snake["body"][block_index - 1] - block
			var compress = previous_block + next_block
			
			if previous_block.x == -1 and next_block.y == -1:
				set_snake(block, layer, "nw-turn-up", wrapping)
			elif next_block.x == -1 and previous_block.y == -1:
				set_snake(block, layer, "nw-turn-left", wrapping)
			elif previous_block.x == -1 and next_block.y == 1:
				set_snake(block, layer, "sw-turn-down", wrapping)
			elif next_block.x == -1 and previous_block.y == 1:
				set_snake(block, layer, "sw-turn-left", wrapping)
			elif previous_block.x == 1 and next_block.y == -1:
				set_snake(block, layer, "ne-turn-up", wrapping)
			elif next_block.x == 1 and previous_block.y == -1:
				set_snake(block, layer, "ne-turn-right", wrapping)
			elif previous_block.x == 1 and next_block.y == 1:
				set_snake(block, layer, "se-turn-down", wrapping)
			elif next_block.x == 1 and previous_block.y == 1:
				set_snake(block, layer, "se-turn-right", wrapping)
			#screen wrap turning (also impossible for next_block to have 24 as any value)
			elif compress.x == 24 and compress.y == -1:
				set_snake(block, layer, "nw-turn-up", wrapping)#yes
			elif compress.x == -1 and compress.y == 24:
				set_snake(block, layer, "nw-turn-left", wrapping)#yes
			elif compress.x == 24 and compress.y == 1:
				set_snake(block, layer, "sw-turn-down", wrapping)#yes
			elif compress.x == -1 and compress.y == -24:
				set_snake(block, layer, "sw-turn-left", wrapping)#yes
			elif compress.x == -24 and compress.y == -1:
				set_snake(block, layer, "ne-turn-up", wrapping)#yes
			elif compress.x == 1 and compress.y == 24:
				set_snake(block, layer, "ne-turn-right", wrapping)#yes
			elif compress.x == -24 and compress.y == 1:
				set_snake(block, layer, "se-turn-down", wrapping) #yes
			elif compress.x == 1 and compress.y == -24:
				set_snake(block, layer, "se-turn-right", wrapping)#yes
			
			#no turning has occured
			elif head_dir == 'right': 
				set_snake(block, layer, "head-exit-right", wrapping)
			elif head_dir == 'left': 
				set_snake(block, layer, "head-exit-left", wrapping)
			elif head_dir == 'up': 
				set_snake(block, layer, "head-exit-up", wrapping)
			elif head_dir == 'down': 
				set_snake(block, layer, "head-exit-down", wrapping)
	#body -> tail
		elif block_index == snake["body"].size()-2:
			var tail_dir = relation2(snake["body"][-1], snake["body"][-2])
			if tail_dir == null: return
			#tail_dir = which direction the end tail points to
			var previous_block = snake["body"][block_index + 1] - block
			var next_block = snake["body"][block_index - 1] - block
			#order matters
			if previous_block.x == -1 and next_block.y == -1:
				set_snake(block, layer, "nw-move-up", wrapping)
			elif next_block.x == -1 and previous_block.y == -1:
				set_snake(block, layer, "nw-move-left", wrapping)
			elif previous_block.x == -1 and next_block.y == 1:
				set_snake(block, layer, "sw-move-down", wrapping)
			elif next_block.x == -1 and previous_block.y == 1:
				set_snake(block, layer, "sw-move-left", wrapping)
			elif previous_block.x == 1 and next_block.y == -1:
				set_snake(block, layer, "ne-move-up", wrapping)
			elif next_block.x == 1 and previous_block.y == -1:
				set_snake(block, layer, "ne-move-right", wrapping)
			elif previous_block.x == 1 and next_block.y == 1:
				set_snake(block, layer, "se-move-down", wrapping)
			elif next_block.x == 1 and previous_block.y == 1:
				set_snake(block, layer, "se-move-right", wrapping)
				
			#screen wrapping turning (also impossible for next_block to have 24 as any value)
			elif (next_block.x == 24 and previous_block.y == -1) or (next_block.x == -1 and previous_block.y == 24):
				set_snake(block, layer, "nw-move-left", wrapping)#yes
			elif (previous_block.x == -1 and next_block.y == 24) or (previous_block.x == 24 and next_block.y == -1):
				set_snake(block, layer, "nw-move-up", wrapping)#yes
			elif (next_block.x == 24 and previous_block.y == 1) or (next_block.x == -1 and previous_block.y == -24):
				set_snake(block, layer, "sw-move-left", wrapping)#yes
			elif (previous_block.x == -1 and next_block.y == -24) or (previous_block.x == 24 and next_block.y == 1):
				set_snake(block, layer, "sw-move-down", wrapping)#yes
			elif (next_block.x == -24 and previous_block.y == -1) or (next_block.x == 1 and previous_block.y == 24):
				set_snake(block, layer, "ne-move-right", wrapping)#yes
			elif (previous_block.x == 1 and next_block.y == 24) or (previous_block.x == -24 and next_block.y == -1):
				set_snake(block, layer, "ne-move-up", wrapping)#yes
			elif (next_block.x == -24 and previous_block.y == 1) or (next_block.x == 1 and previous_block.y == -24):
				set_snake(block, layer, "se-move-right", wrapping) #yes
			elif (previous_block.x == 1 and next_block.y == -24) or (previous_block.x == -24 and next_block.y == 1):
				set_snake(block, layer, "se-move-down", wrapping)#yes
				
			#no turning has occured
			elif tail_dir == 'right': 
				set_snake(block, layer, "body-move-left", wrapping)
			elif tail_dir == 'left': 
				set_snake(block, layer, "body-move-right", wrapping)
			elif tail_dir == 'up': 
				set_snake(block, layer, "body-move-down", wrapping)
			elif tail_dir == 'down': 
				set_snake(block, layer, "body-move-up", wrapping)
		#tail
		elif block_index == snake["body"].size()-1:
			var tail_dir = relation2(snake["body"][-1], snake["body"][-2])
			if tail_dir == null: return
			#tail_dir = which direction the end tail points to
			if tail_dir == 'right': 
				set_snake(block, layer, "tail-move-right", wrapping)
			elif tail_dir == 'left': 
				set_snake(block, layer, "tail-move-left", wrapping)
			elif tail_dir == 'up': 
				set_snake(block, layer, "tail-move-up", wrapping)
			elif tail_dir == 'down': 
				set_snake(block, layer, "tail-move-down", wrapping)
		else:
			var previous_block = snake["body"][block_index + 1] - block
			var next_block = snake["body"][block_index - 1] - block
			#going vertical
			if previous_block.x == next_block.x:
				set_snake(block, layer, "body-vertical", wrapping)
			#going horizontal
			elif previous_block.y == next_block.y:
				set_snake(block, layer, "body-horizontal", wrapping) 
			else:
				var compress = previous_block + next_block
				if compress.x == -1 and compress.y == -1:
					set_snake(block, layer, "body-nw", wrapping)
				elif compress.x == -1 and compress.y == 1:
					set_snake(block, layer, "body-sw", wrapping)
				elif compress.x == 1 and compress.y == -1:
					set_snake(block, layer, "body-ne", wrapping)
				elif compress.x == 1 and compress.y == 1:
					set_snake(block, layer, "body-se", wrapping)
				#screen wrapping
				#nw (-1,24) (24,-1) (24,-1) (-1,24)
				elif compress.x == -1 and compress.y == 24 or compress.x == 24 and compress.y == -1:
					set_snake(block, layer, "body-nw", wrapping)
				elif compress.x == -1 and compress.y == -24 or compress.x == 24 and compress.y == 1:
					set_snake(block, layer, "body-sw", wrapping)
				elif compress.x == 1 and compress.y == 24 or compress.x == -24 and compress.y == -1:
					set_snake(block, layer, "body-ne", wrapping)
				elif compress.x == 1 and compress.y == -24 or compress.x == -24 and compress.y == 1:
					set_snake(block, layer, "body-se", wrapping)
func set_snake(block, layer, part_type : String, wrapping = true, override = false):
	#if it would place it out of bounds, wrap it
	if(wrapping == true):
		var x = wrapi(block.x, 0 ,25)
		var y = wrapi(block.y, 0 ,25)
		set_cell(Vector2(x, y), layer, part_type, override)
		#$SnakeApple.set_cell(layer, Vector2i(x, y), part_type, Vector2i(0,0), 0)
	else:
		set_cell(Vector2(block.x, block.y), layer, part_type, override)
		#$SnakeApple.set_cell(layer, Vector2i(block.x, block.y), part_type, Vector2i(0,0), 0)
#func set_snake(block, layer, part_name : String, wrapping = true):
#	set_snake_int(block, layer, TILE_PARTS[part_name], wrapping)
	
func relation2(first_block, second_block):
	if(first_block == null or second_block == null): return null
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
	
func game_is_over():
	game_over.emit()
	$SnakeTick.stop()
	$EnemySpawnTimer.stop()
	$GameTimer.stop()
	
	
	for enemy in enemy_snakes: #stop enemy snakes
		enemy["body"] = enemy["body"].slice(1,enemy["body"].size()-1)
		draw_still_snake(enemy["type"], enemy)
		enemy["status"] = DEAD
		
		
	

func move_snake(layer, snake):
	if get_tree().paused: return
	if snake["status"] == DEAD or snake["status"] == DYING: 
		return snake
		
		
	delete_tiles(snake["body"][-1], layer) #delete the tail
	if snake["status"] == SPAWNING:
		snake["status"] = SPAWNED
		return
		
	var body_copy
	if snake["grow"]: #if player
		body_copy = snake["body"].slice(0,snake["body"].size())
		snake["grow"] = false
		
	else:
		# take everything except the last index in the body (tail)
		body_copy = snake["body"].slice(0,snake["body"].size()-1)
	if snake["direction"] == null: return
	var new_head = body_copy[0] + snake["direction"]
	#detect collisions
	var id = check_collision(new_head)
	if id != null and id["tile"] != null:#not empty space
		#if collision, attempt to move away
		if snake["type"] != SNAKE:
			var attempts = snake["rerouting"]
			while id != null and attempts > 0:
				snake["direction"] = choose_direction([snake["direction"] * -1])
				new_head = body_copy[0] + snake["direction"]
				id = check_collision(new_head)
				attempts -= 1
			if id != null and id["tile"] != null:
				return kill_snake(layer, snake, body_copy)
		else: #otherwise kill
			#head on collision, kill other snake
			if id["name"].contains("head") or id["name"].contains("bonk"):
				
				if id["name"].contains("up") and snake["direction"].y == 1:
					return 
				elif id["name"].contains("down") and snake["direction"].y == -1:
					return
				elif id["name"].contains("left") and snake["direction"].x == 1:
					return
				elif id["name"].contains("right") and snake["direction"].x == -1:
					return
			kill_snake(layer, snake, body_copy)
			return
	
	
	body_copy.insert(0, new_head)
	snake["body"] = body_copy

func basic_enemy_movement(snake):
	if snake["status"] == DEAD or snake["status"] == DYING: return
	if snake["status"] == SPAWNING:
		snake["status"] = SPAWNED
		return
	if snake["direction"] == null: return
	if snake["basic_turn"] <= 0:
		snake["direction"] = choose_direction([snake["direction"] * -1])
		var when_turn = randi_range(1,10)
		if snake["type"] == ENEMY_LONG: when_turn = randi_range(10,15)
		snake["basic_turn"] = when_turn
	else:
		snake["basic_turn"] -= 1
func hunting_enemy_movement(snake):
	if snake["status"] == DEAD or snake["status"] == DYING: return
	if player_snake["status"] == DEAD or player_snake["status"] == DYING:
		basic_enemy_movement(snake)
		return
	if snake["status"] == SPAWNING:
		snake["status"] = SPAWNED
		return
	if snake["direction"] == null: return
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
	var future_position = check_collision(snake["body"][0] + snake["direction"])
	while (future_position != null and future_position["tile"] != null) and attempts > 0:
		snake["direction"] = choose_direction(banned)
		banned.append(snake["direction"])
		future_position = check_collision(snake["body"][0] + snake["direction"])
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
	
	if snake["type"] == SNAKE: 
		game_is_over()
		return
	var difference = snake["body"][0] - player_snake["body"][0]
	var distance = max(abs(difference.x), abs(difference.y))
	var multipler = 1
	if distance <= 1: multipler = 7
	elif distance == 2: multipler = 5
	elif distance == 3: multipler = 3
	elif distance <= 5: multipler = 2
	update_score(int((player_snake["body"].size()-3) * snake["body"].size() * multipler), $SnakeApple.map_to_local(snake["body"][0]))
	play_sound("res://audio/enemySnakeDeath.wav")
	
		#spawn food
	var ignore_first = true
	for part in snake["body"]:
		delete_tiles(part, layer)
		if randi_range(0,2) == 0 or ignore_first: #1/3 chance to spawn food
			ignore_first = false
			set_cell(Vector2i(part.x, part.y), FOOD, "meat")
			#$SnakeApple.set_cell(FOOD, Vector2i(part.x, part.y), TILE_PARTS["meat"], Vector2i(0,0),0)
	spawn_snake()
	return snake
	
func delete_tiles(position, layer):
	if position == null: return
	set_cell(position, layer)
	#$SnakeApple.set_cell(layer, position, -1)
		
var collision_layers = [SNAKE, ENEMY_BASIC, ENEMY_HUNTER, ENEMY_LONG]
#return true if collision happens
func check_collision(position):
	position.x = wrapi(position.x, 0, 25)
	position.y = wrapi(position.y, 0 ,25)
	for i in collision_layers:
		var id = get_cell(position, i)
		#var id = $SnakeApple.get_cell_source_id(i, position)
		if id["tile"] != null:
			if id["name"].contains("tail"): return null
			return id
	return null

var recently_pressed = 0
func _input(event):
	if Input.is_physical_key_pressed(KEY_SPACE): get_tree().reload_current_scene()
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
	
	#initalize position
	for i in range(-1,26):
		for j in range(-1,26):
			var key = str(i) + ":" + str(j)
			tile_positions[key] = {}
			for k in range(1,6):
				tile_positions[key][k] = {"name":"empty","tile":null}
	apple_positions.push_back(Vector2(randi_range(0,24),randi_range(0,24)))
	apple_positions.push_back(Vector2(randi_range(0,24),randi_range(0,24)))
	
	#pre_spawn player
	draw_snake(SNAKE, player_snake)
		#$SnakeApple.set_cell(0,Vector2i(0,0),1,Vector2i(0,0),0)
	
	
func place_apple():
	var attempts = 10
	var collide = true
	var pos
	while collide == true and attempts > 0:
		randomize()
		var x = randi() % 24
		var y = randi() % 24
		if get_cell(Vector2(x,y), FOOD)["tile"] == null:
		#if $SnakeApple.get_cell_source_id(FOOD, Vector2(x,y)) == -1:
			collide = false
			pos = Vector2(x,y)
		attempts -= 1
	return pos
	
func draw_apple():
	for apple in apple_positions:
		set_cell(apple, FOOD, "apple")
		
		
	
func check_snake_out_of_map(snake):
	if snake["status"] == DEAD: return
	var head = snake["body"][0]
	if head == null: return
	if head.x > 24:
		snake["body"][0].x = 0
	elif head.x < 0:
		snake["body"][0].x = 24
	elif head.y > 24:
		snake["body"][0].y = 0
	elif head.y < 0:
		snake["body"][0].y = 24

func check_food_eaten(snake):
	if snake["status"] == DEAD or snake["spawn_count"] > 0: return
	var position = snake["body"][1]
	var food_type = get_cell(position, FOOD)#$SnakeApple.get_cell_source_id(FOOD, position)
	if food_type["tile"] != null:
		#grow body smoothly
		var tile = get_cell(snake["body"][-1], snake["type"])["name"]#$SnakeApple.get_cell_source_id(SNAKE, player_snake["body"][-1])
		var tail = "empty"
		if (tile == "tail-move-left" or tile == "body-horizontal"): tail = "tail-left"
		elif (tile == "tail-move-right" or tile == "body-horizontal"): tail = "tail-right"
		elif (tile == "tail-move-up" or tile == "body-vertical"): tail = "tail-up"
		elif (tile == "tail-move-down" or tile == "body-vertical"): tail = "tail-down"
		
		var body = get_cell(snake["body"][-2], snake["type"])["name"]#$SnakeApple.get_cell_source_id(SNAKE, player_snake["body"][-2])
		if(body == "ne-move-up" or body == "ne-move-right"): tile = "body-ne"
		elif(body == "nw-move-up" or body == "nw-move-left"): tile = "body-nw"
		elif(body == "se-move-down" or body == "se-move-right"): tile = "body-se"
		elif(body == "sw-move-down" or body == "sw-move-left"): tile = "body-sw"
		elif(tile == "tail-move-left" or tile == "tail-move-right"): tile = "body-horizontal"
		elif(tile == "tail-move-up" or tile == "tail-move-down"): tile = "body-vertical"
		
		if snake["body"][-2] != null and snake["body"][-1] != null:
			set_snake(snake["body"][-2], snake["type"], tile, true, true)
			set_snake(snake["body"][-1], snake["type"], tail, true, true)
		
		delete_tiles(position, FOOD)
		if food_type["name"] == "apple":
			apple_positions.erase(position)
			apple_positions.push_back(place_apple())
			if snake["type"] == SNAKE: play_sound("res://audio/appleEat2.wav", -5)
		elif food_type["name"] == "meat" and snake["type"] == SNAKE: play_sound("res://audio/deadSnakeEat4Short.wav", -5)
			
		snake["grow"] = true
		if snake["spawn_count"] > 0:
			snake["spawn_count"] += 1
		if snake["type"] == SNAKE:
			update_score((player_snake["body"].size()-3) * 10, $SnakeApple.map_to_local(position))
		
func update_score(value, bubble_position = null):
	if bubble_position != null:
		var child = floating_text.instantiate()
		child.set_text(value)
		child.global_position = bubble_position
		$Text_Storage.add_child(child)
	score += value
	get_tree().call_group('ScoreGroup', 'update_score', score)

func _on_snake_tick_timeout():
	if player_snake["status"] == DEAD or player_snake["status"] == DYING:
		move_snake(SNAKE, player_snake)
		draw_snake(SNAKE, player_snake)
		return
	#enemies
	var pending_removal = []
	for enemy in enemy_snakes:
		var type = enemy["type"]
		
		if(type == ENEMY_BASIC or type == ENEMY_LONG):
			basic_enemy_movement(enemy)
		elif(type == ENEMY_HUNTER):
			hunting_enemy_movement(enemy)
		var snake = move_snake(type, enemy)
		if snake == enemy: 
			pending_removal.push_back(enemy)
			continue
		
		draw_snake(type, enemy)
		check_food_eaten(enemy)
		check_snake_out_of_map(enemy)
	#player
	move_snake(SNAKE, player_snake)
	draw_snake(SNAKE, player_snake)
	check_food_eaten(player_snake)
	draw_apple()
	check_snake_out_of_map(player_snake)
	for enemy in pending_removal:
		enemy_snakes.erase(enemy)

func _on_timer_timeout():
	timer += 1
	get_tree().call_group('ScoreGroup', 'update_timer', timer)
	update_score(1)
	
func _on_enemy_spawn_timer_timeout():
	spawn_snake()
	
func set_cell(position : Vector2, layer : int, tile_part = "empty", override = false):
	var key = str(position.x) + ":" + str(position.y)
	if override == false and tile_part.contains("tail") and !tile_part.contains("move"):
		return
	if tile_part == "empty": #remove cell
		if tile_positions[key][layer]["tile"] == null: return
		tile_positions[key][layer]["tile"].queue_free()
		tile_positions[key][layer] = {"name":"empty","tile":null}
		if layer != FOOD:
			if position.x == 0 or position.x == -1:
				$SnakeApple.set_cell(0, Vector2i(24, position.y), -1)
			elif position.x == 24 or position.x == 25:
				$SnakeApple.set_cell(0, Vector2i(0, position.y), -1)
			elif position.y == 0 or position.y == -1:
				$SnakeApple.set_cell(0, Vector2i(position.x, 24), -1)
			elif position.y == 24 or position.y == 25:
				$SnakeApple.set_cell(0, Vector2i(position.x, 0), -1)
		
	else:
		
		#print(tile_positions[key][layer]["name"])
		#var value = tile_positions.find_key(key) 
		#print(value)
		#if value == null:
		#	tile_positions[key] = {}
		
		var tile = tile_piece.instantiate()
		tile.layer = layer
		tile.animation_name = tile_part
		tile.global_position = $SnakeApple.map_to_local(position)
		if layer == FOOD:
			$Food_Storage.add_child(tile)
		else:
			$Tile_Storage.add_child(tile)
			
		#play sound if player turns
		if layer == SNAKE and tile_part.contains("turn"):
			play_sound("res://audio/changeDirection.wav", -10)
		
		#replace if duplicate
		var previous = tile_positions[key][layer]["name"]
		if previous != "empty":
			tile_positions[key][layer]["tile"].queue_free()
		if layer != FOOD:
			if position.x == 0 or position.x == -1:
				$SnakeApple.set_cell(0, Vector2i(24, position.y), 3, Vector2i(1,0),0)
			elif position.x == 24 or position.x == 25:
				$SnakeApple.set_cell(0, Vector2i(0, position.y), 3, Vector2i(0,1),0)
			elif position.y == 0 or position.y == -1:
				$SnakeApple.set_cell(0, Vector2i(position.x, 24), 3, Vector2i(1,1),0)
			elif position.y == 24 or position.y == 25:
				$SnakeApple.set_cell(0, Vector2i(position.x, 0), 3, Vector2i(0,0),0)
		
		tile_positions[key][layer] = {"name":tile_part,"tile":tile}
		
	
	#$SnakeApple.set_cell(FOOD, Vector2i(position.x, position.y), tile_part, Vector2i(0,0),0)

func get_cell(position : Vector2, layer : int):
	var key = str(position.x) + ":" + str(position.y)
	var value = tile_positions[key][layer]
	return value
		
	#return $SnakeApple.get_cell_source_id(i, position)
	
func play_sound(string, volume = 0):
	var audio = one_shot.instantiate()
	add_child(audio)
	audio.set_stream(load(string))
	audio.play()
	audio.volume_db = volume
	
