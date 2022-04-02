extends Node2D

export (int) var health


func table_damage(damage):
	health -= damage
