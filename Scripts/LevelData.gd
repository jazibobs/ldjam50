extends Node

var level


func _ready():
	# var level_data_file = File.new()
	# level_data_file.open("res://Data/levels.json", File.READ)
	# var level_data_json = JSON.parse(level_data_file.get_as_text())
	# level_data_file.close()
	# level = level_data_json.result
	
	
	level = {
		"L1": {
			"colours": ["pink", "blue", "green", "yellow"],
			"empty": [],
			"timer": 99,
			"matches" : 100
		},
		"L2": {
			"colours": ["pink", "blue", "green", "yellow"],
			"empty": [
				[0, 0],
				[7, 0],
				[0, 9],
				[7, 9]
			],
			"timer": 99,
			"matches" : 100
		},
		"L3": {
			"colours": ["pink", "blue", "green", "yellow", "red"],
			"empty": [
				[0, 0],
				[7, 0],
				[0, 9],
				[7, 9],
				[3, 4],
				[4, 4],
				[3, 5],
				[4, 5]
			],
			"timer": 99,
			"matches" : 100
		},
		"L4": {
			"colours": ["pink", "blue", "green", "yellow", "red", "purple"],
			"empty": [
				[0, 0],
				[7, 0],
				[0, 9],
				[7, 9],
				[3, 4],
				[4, 4],
				[3, 5],
				[4, 5]
			],
			"timer": 99,
			"matches" : 100
		},
		"L5": {
			"colours": ["pink", "blue", "green", "yellow", "red", "purple", "white"],
			"empty": [
				[1, 1],
				[6, 1],
				[1, 8],
				[6, 8],
				[3, 4],
				[4, 4],
				[3, 5],
				[4, 5]
			],
			"timer": 99,
			"matches" : 100
		},
		"L6": {
			"colours": ["pink", "blue", "green", "yellow", "red", "purple", "white"],
			"empty": [
				[0, 4],
				[0, 5],
				[1, 4],
				[1, 5],
				[6, 4],
				[6, 5],
				[7, 4],
				[7, 5]
			],
			"timer": 99,
			"matches" : 100
		},
		"L7": {
			"colours": ["pink", "blue", "green", "yellow", "red", "purple", "white", "sky"],
			"empty": [
				[1, 1],
				[6, 1],
				[1, 8],
				[6, 8],
				[3, 4],
				[4, 4],
				[3, 5],
				[4, 5]
			],
			"timer": 99,
			"matches" : 100
		},
		"L8": {
			"colours": ["pink", "blue", "green", "yellow", "red", "purple", "white", "sky"],
			"empty": [
				[0, 4],
				[0, 5],
				[1, 4],
				[1, 5],
				[6, 4],
				[6, 5],
				[7, 4],
				[7, 5]
			],
			"timer": 99,
			"matches" : 100
		}
	}
