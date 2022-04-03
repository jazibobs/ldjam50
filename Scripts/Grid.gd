extends Node2D

enum {wait, move, win, lose, next_level, game_over}
var state
var current_level = 1
var matches_needed = 20
var time_remaining = 99
var monster_step = 5

# Grid vars
export (int) var width
export (int) var height
export (int) var x_start
export (int) var y_start
export (int) var offset
export (int) var new_piece_offset

export (PoolVector2Array) var empty_spaces

var piece_node = preload("res://Objects/Piece.tscn")
var possible_colours = ['pink', 'blue', 'green', 'yellow', 'red', 'purple', 'white', 'sky']
var all_pieces = []

var piece_one = null
var piece_two = null
var last_place = Vector2(0,0)
var last_direction = Vector2(0,0)
var move_checked = false

var touch_start = Vector2(0,0)
var touch_end = Vector2(0,0)
var controlling = false

# Called when the node enters the scene tree for the first time.
func _ready():
	state = move
	randomize()
	load_level_data(current_level)


func _process(_delta):
	if state == move:
		touch_input()
	elif state == win:
		state = next_level
		end_of_level(current_level)
	elif state == lose:
		state = next_level
		end_of_level(-1)
		
	if matches_needed <= 0 && time_remaining > 0 && state != next_level:
		state = win
	elif time_remaining < 0 && state != next_level:
		state = lose


func load_level_data(level_number):
	var level_key = "L" + str(level_number)
	possible_colours = LevelData.level[level_key].colours
	
	while !empty_spaces.empty():
		empty_spaces.remove(0)
	
	for cell in LevelData.level[level_key].empty:
		empty_spaces.append(Vector2(cell[0], cell[1]))
	
	get_parent().get_node("PlayerInfo/DayInfo").text = "Day " + str(level_number)
	
	matches_needed = LevelData.level[level_key].matches
	get_parent().get_node("PlayerInfo/Matches/MatchesText").text = str(matches_needed)
	
	time_remaining = LevelData.level[level_key].timer
	get_parent().get_node("PlayerInfo/Timer/TimerText").text = str(time_remaining)
	get_parent().get_node("Seconds").start()
	
	# The x offset travelled by the monster with each passing of the timer
	# Monster start pos -135, end pos 320
	monster_step = (320 - -135) / time_remaining
	
	all_pieces = make_pieces_array()
	spawn_pieces()
	move_checked = false


func end_of_level(level):
	get_parent().get_node("DestroyPieces").stop()
	get_parent().get_node("CollapseGrid").stop()
	get_parent().get_node("RefillGrid").stop()
	get_parent().get_node("Seconds").stop()
	if level == -1:
		get_parent().get_node("GameOverContent").visible = true
		get_parent().get_node("EndOfLevelAnimation").play("game_over_fade")
	else:
		get_parent().get_node("NextLevelContent").visible = true
		get_parent().get_node("EndOfLevelAnimation").play("fade_out")
		get_parent().get_node("PlayerInfo/Monster/MonsterWalk").stop()
		get_parent().get_node("PlayerInfo/Monster").set_flip_h(true)
		get_parent().get_node("PlayerInfo/Monster").move(Vector2(-500, 1000))


func make_pieces_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null)
	return array


func restricted_movement(place):
	for i in empty_spaces.size():
		if empty_spaces[i] == place:
			return true
	return false


func spawn_pieces():
	for child in get_node(".").get_children():
		get_node(".").remove_child(child)
		child.queue_free()
		
	for i in width:
		for j in height:
			if !restricted_movement(Vector2(i, j)):
				var rand = floor(rand_range(0, possible_colours.size()))
				var piece_colour = possible_colours[rand]
				var new_piece = piece_node.instance()
				new_piece.init(piece_colour)
				var loops = 0
				
				while(match_at(i, j, piece_colour) && loops < 100):
					rand = floor(rand_range(0, possible_colours.size()))
					piece_colour = possible_colours[rand]
					new_piece = piece_node.instance()
					new_piece.init(piece_colour)
				
				add_child(new_piece);
				new_piece.position = grid_to_pixel(i, j);
				all_pieces[i][j] = new_piece


func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_colour = all_pieces[i][j].colour
				if i > 0 && i < width - 1:
					if all_pieces[i - 1][j] != null && all_pieces[i + 1][j] != null:
						if all_pieces[i - 1][j].colour == current_colour && all_pieces[i + 1][j].colour == current_colour:
							all_pieces[i - 1][j].matched = true
							all_pieces[i - 1][j].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i + 1][j].matched = true
							all_pieces[i + 1][j].dim()
				
				if j > 0 && j < height - 1:
					if all_pieces[i][j - 1] != null && all_pieces[i][j + 1] != null:
						if all_pieces[i][j - 1].colour == current_colour && all_pieces[i][j + 1].colour == current_colour:
							all_pieces[i][j - 1].matched = true
							all_pieces[i][j - 1].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i][j + 1].matched = true
							all_pieces[i][j + 1].dim()
	get_parent().get_node("DestroyPieces").start()


func destroy_matched():
	var was_matched = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					was_matched = true
					matches_needed -= 1
					get_parent().get_node("PlayerInfo/Matches/MatchesText").text = str(matches_needed if matches_needed > 0 else 0)
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
	move_checked = true
	if was_matched:
		get_parent().get_node("ClearSound").play()
		get_parent().get_node("CollapseGrid").start()
	else:
		swap_back()


func collapse_columns():
	get_parent().get_node("PlayerInfo/Monster/PainAudio").play()
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !restricted_movement(Vector2(i, j)):
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("RefillGrid").start()

func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !restricted_movement(Vector2(i, j)):
				var rand = floor(rand_range(0, possible_colours.size()))
				var piece_colour = possible_colours[rand]
				var new_piece = piece_node.instance()
				new_piece.init(piece_colour)
				var loops = 0
			
				while(match_at(i, j, piece_colour) && loops < 100):
					rand = floor(rand_range(0, possible_colours.size()))
					piece_colour = possible_colours[rand]
					new_piece = piece_node.instance()
					new_piece.init(piece_colour)
				
				add_child(new_piece);
				new_piece.position = grid_to_pixel(i, j + new_piece_offset);
				new_piece.move(grid_to_pixel(i, j))
				all_pieces[i][j] = new_piece
	after_refill()


func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].colour):
					find_matches()
					get_parent().get_node("DestroyPieces").start()
					return
	state = move
	move_checked = false

func match_at(col, row, colour):
	if col > 1:
		if all_pieces[col - 1][row] != null && all_pieces[col - 2][row] != null:
			if all_pieces[col - 1][row].colour == colour && all_pieces[col - 2][row].colour == colour:
				return true
	
	if row > 1:
		if all_pieces[col][row - 1] != null && all_pieces[col][row - 2] != null:
			if all_pieces[col][row - 1].colour == colour && all_pieces[col][row - 2].colour == colour:
				return true


func grid_to_pixel(col, row):
	var new_x = x_start + offset * col
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)


func pixel_to_grid(touch_x, touch_y):
	var grid_x = round((touch_x - x_start) / offset)
	var grid_y = round((touch_y - y_start) / -offset)
	return Vector2(grid_x, grid_y)


func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
	return false


func touch_input():
	var mouse = get_global_mouse_position()
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(mouse.x, mouse.y)):
			touch_start = pixel_to_grid(mouse.x, mouse.y);
			controlling = true
	
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(mouse.x, mouse.y)) && controlling:
			touch_end = pixel_to_grid(mouse.x, mouse.y);
			touch_difference(touch_start, touch_end)
		controlling = false


func swap_pieces(col, row, direction):
	var first_piece = all_pieces[col][row]
	var other_piece = all_pieces[col + direction.x][row + direction.y]
	
	if first_piece != null && other_piece != null:
		pieces_moved(first_piece, other_piece, Vector2(col, row), direction)
		state = wait
		all_pieces[col][row] = other_piece
		all_pieces[col + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(col + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(col, row))
		if !move_checked:
			find_matches()


func pieces_moved(first_piece, other_piece, place, direction):
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction


func swap_back():
	# Move pieces back to prev location if no matches
	if piece_one != null && piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = move
	move_checked = false


func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0))
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))


func _on_DestroyPieces_timeout():
	destroy_matched()


func _on_CollapseGrid_timeout():
	collapse_columns()
	get_parent().get_node("PlayerInfo/Monster").modulate = Color(1, 0.5, 0.5)
	get_parent().get_node("PlayerInfo/Matches").modulate = Color(1, 0.5, 0.5)


func _on_RefillGrid_timeout():
	refill_columns()
	get_parent().get_node("PlayerInfo/Monster").modulate = Color(1, 1 ,1)
	get_parent().get_node("PlayerInfo/Matches").modulate = Color(1, 1, 1)


func _on_Seconds_timeout():
	time_remaining -= 1
	get_parent().get_node("PlayerInfo/Timer/TimerText").text = str(time_remaining if time_remaining > 0 else 0)
	
	var monster_location = get_parent().get_node("PlayerInfo/Monster").position
	var monster_new_location = Vector2(monster_location.x + monster_step, monster_location.y)
	get_parent().get_node("PlayerInfo/Monster").move(monster_new_location)


func _on_TitleButton_pressed():
	get_parent().get_node("EndOfLevelAnimation").play("full_fade")


func _on_NextLevel_pressed():
	current_level += 1
	load_level_data(current_level)
	get_parent().get_node("PlayerInfo/Monster").move(Vector2(-135, 943))
	get_parent().get_node("PlayerInfo/Monster").set_flip_h(false)
	get_parent().get_node("PlayerInfo/Monster/MonsterWalk").play()
	get_parent().get_node("EndOfLevelAnimation").play("level_fade_in")
	state = move


func _on_EndOfLevelAnimation_animation_finished(anim_name):
	if anim_name == "full_fade":
		get_tree().change_scene("res://Scenes/Title.tscn")
	elif anim_name == "level_fade_in":
		get_parent().get_node("NextLevelContent").visible = false
