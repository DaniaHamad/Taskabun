extends Control



func _on_BackButton_pressed():
	Music.play_BtnFX()
	get_tree().change_scene("res://UI/Main.tscn")
