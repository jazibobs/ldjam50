extends Sprite


func _ready():
	$MonsterWalk.play("monster_move")


func move(target):
	$MovingTween.interpolate_property(
		self, "position", position, target, 1, 
		Tween.TRANS_BOUNCE, Tween.EASE_OUT
	);
	$MovingTween.start()
