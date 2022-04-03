extends Node

var level


func _ready():
	var level_data_file = File.new()
	level_data_file.open("res://Data/levels.json", File.READ)
	var level_data_json = JSON.parse(level_data_file.get_as_text())
	level_data_file.close()
	level = level_data_json.result
