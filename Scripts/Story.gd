extends Node


func _ready():
	$AnimationPlayer.play("story_fade")


func _on_StartButton_pressed():
	$AnimationPlayer.play("story_fade_out")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "story_fade_out":
		get_tree().change_scene("res://Scenes/GameWindow.tscn")
