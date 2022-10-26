extends Node2D
var speed=0


func _physics_process(delta):
	speed+=.1
	$DownScene.position.y+=speed
	$LeftScene.position.x-=speed
	$RightScene.position.x+=speed
	
