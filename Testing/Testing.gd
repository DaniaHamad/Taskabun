extends Node2D

var array = [
	[5,5],
	[10,10],
	[13,14]
]
var greenWayEmptyTilePos=[
	[96,-32],
	[416,-32],
	[544,-32],
	[608,-96],
	[544,-96],
	[288,-96],
	[160,-96],
	[96,-96],
	[32,-160],
	[352,-160],
	[480,-160],
	[608,-160],
	[544,-224],
	[480,-224],
	[416,-224],
	[160,-224],
	[96,-224],
]
onready var position2d = $Position2D
func _ready():
	var temp = [int(position2d.position.x),int(position2d.position.y)]
	if greenWayEmptyTilePos.has(temp):
		print("true")
	else:
		print("false")
	print(greenWayEmptyTilePos.find(temp))
	greenWayEmptyTilePos.remove(greenWayEmptyTilePos.find(temp))
	for i in greenWayEmptyTilePos:
		print(i)
