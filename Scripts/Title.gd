extends Control


func _on_CreditsButton_pressed():
	$AnimationPlayer.play("fade_to_credits")


func _on_StartButton_pressed():
	$AnimationPlayer.play("fade_to_game")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_to_game":
		get_tree().change_scene("res://Scenes/Story.tscn")
	elif anim_name == "fade_to_credits":
		get_tree().change_scene("res://Scenes/Credits.tscn")
