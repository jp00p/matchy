extends Node


func _on_PlayTNG_pressed():
	GLOBALS.selected_game = "tng"
	start_game()

func _on_PlayDS9_pressed():
	GLOBALS.selected_game = "ds9"
	start_game()

func start_game():
	get_tree().change_scene("res://Table.tscn")
