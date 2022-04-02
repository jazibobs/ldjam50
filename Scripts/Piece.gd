extends Node2D

export (String) var colour;

var possible_colours = ['sky', 'blue', 'pink', 'purple', 'red', 'orange', 'green', 'grey'];

func init(colour):
	self.colour = colour;
	var frame = possible_colours.find(colour);
	$AnimatedSprite.frame = frame;
	# print("Setting frame", frame, "for colour", colour)


func _ready():
	pass
