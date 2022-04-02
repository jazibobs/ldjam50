extends Node2D

# Grid vars
export (int) var width;
export (int) var height;
export (int) var x_start;
export (int) var y_start;
export (int) var offset;

var piece_node = preload("res://Objects/Piece.tscn");
var possible_colours = ['sky', 'blue', 'pink', 'purple', 'red', 'orange', 'green', 'grey'];
var all_pieces = [];

var touch_start = Vector2(0,0);
var touch_end = Vector2(0,0);

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize();
	all_pieces = make_pieces_array();
	spawn_pieces();

func _process(delta):
	touch_input();0

func make_pieces_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null)
	return array;


func spawn_pieces():
	for i in width:
		for j in height:
			var rand = floor(rand_range(0, possible_colours.size()));
			var piece_colour = possible_colours[rand];
			var new_piece = piece_node.instance();
			new_piece.init(piece_colour);
			var loops = 0;
			
			while(match_at(i, j, piece_colour) && loops < 100):
				rand = floor(rand_range(0, possible_colours.size()));
				piece_colour = possible_colours[rand];
				new_piece = piece_node.instance();
				new_piece.init(piece_colour);
			
			add_child(new_piece);
			new_piece.position = grid_to_pixel(i, j);
			all_pieces[i][j] = new_piece;


func match_at(col, row, colour):
	if col > 1:
		if all_pieces[col - 1][row] != null && all_pieces[col - 2][row] != null:
			if all_pieces[col - 1][row].colour == colour && all_pieces[col - 2][row].colour == colour:
				return true;
	
	if row > 1:
		if all_pieces[col][row - 1] != null && all_pieces[col][row - 2] != null:
			if all_pieces[col][row - 1].colour == colour && all_pieces[col][row - 2].colour == colour:
				return true;


func grid_to_pixel(col, row):
	var new_x = x_start + offset * col;
	var new_y = y_start - offset * row;
	return Vector2(new_x, new_y)


func pixel_to_grid(touch_x, touch_y):
	var grid_x = round((touch_x - x_start) / offset);
	var grid_y = round((touch_y - y_start) / -offset);
	return Vector2(grid_x, grid_y);


func is_in_grid(col, row):
	if col >= 0 && col < width:
		if row >= 0 && row < height:
			return true;
	return false;


func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		touch_start = get_global_mouse_position();
		var grid_position = pixel_to_grid(touch_start.x, touch_start.y)
		print(grid_position)
	if Input.is_action_just_released("ui_touch"):
		touch_end = get_global_mouse_position();
