extends Node2D

export (String) var colour;
var possible_colours = ['sky', 'blue', 'pink', 'purple', 'red', 'orange', 'green', 'grey'];
var matched = false;

func init(received_colour):
	self.colour = received_colour;
	var frame = possible_colours.find(received_colour);
	$AnimatedSprite.frame = frame;


func move(target):
	$MovingTween.interpolate_property(
		self, "position", position, target, .3, 
		Tween.TRANS_BOUNCE, Tween.EASE_OUT
	);
	$MovingTween.start();


func dim():
	$AnimatedSprite.modulate.a = 0.5;
