extends KinematicBody2D

var snakeName = "" setget set_snakeName, get_snakeName
var goBack =1 setget set_goBack,get_goBack
func set_snakeName(name):
	snakeName = name
func get_snakeName():
	return snakeName

func set_goBack(back):
	goBack = back

func get_goBack():
	return goBack
