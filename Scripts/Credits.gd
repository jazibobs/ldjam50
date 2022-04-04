extends Control


func _ready():
	$CreditsAnimation.play("fade_in")


func _on_BackButton_pressed():
	$CreditsAnimation.play("fade_out")


func _on_CreditsAnimation_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().change_scene("res://Scenes/Title.tscn")
