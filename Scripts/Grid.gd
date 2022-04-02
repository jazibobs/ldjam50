extends Node2D

# Grid vars
export (int) var width
export (int) var height
export (int) var x_start
export (int) var y_start
export (int) var offset

var piece_node = preload("res://Objects/Piece.tscn")
var possible_colours = ['sky', 'blue', 'pink', 'purple', 'red', 'orange', 'green', 'grey']
var all_pieces = []

var touch_start = Vector2(0,0)
var touch_end = Vector2(0,0)
var controlling = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	all_pieces = make_pieces_array()
	spawn_pieces()

func _process(delta):
	touch_input()

func make_pieces_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null)
	return array


func spawn_pieces():
	for i in width:
		for j in height:
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
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null


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
		all_pieces[col][row] = other_piece
		all_pieces[col + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(col + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(col, row))
		find_matches()


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
	pass # Replace with function body.
