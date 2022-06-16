extends KinematicBody2D

var snakeName = "" setget set_snakeName, get_snakeName
var goBack =1 setget set_goBack,get_goBack
var snakeHB =1 setget set_snakeHB,get_snakeHB
func set_snakeName(name):
	snakeName = name
func get_snakeName():
	return snakeName

func set_goBack(back):
	goBack = back

func get_goBack():
	return goBack

func set_snakeHB(HB):
	snakeHB = HB
func get_snakeHB():
	return snakeHB
