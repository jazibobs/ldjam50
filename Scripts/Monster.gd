extends Sprite


var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	$MonsterWalk.play("monster_move")


func move(target):
	$MovingTween.interpolate_property(
		self, "position", position, target, 1, 
		Tween.TRANS_BOUNCE, Tween.EASE_OUT
	);
	$MovingTween.start()


func _on_Timer_timeout():
	if rng.randi_range(0, 10) == 5:
		$FireBreath.emitting = true
