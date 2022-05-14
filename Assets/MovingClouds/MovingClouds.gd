extends Node2D

# Called when the node enters the scene tree for the first time.
var direction1=true
var direction2=false
var direction3=true
var x=1920/5

func _physics_process(delta):
	#var x=get_viewport().size.x
	if direction3:
		$cloud3.position.x+=2
		if $cloud3.position.x>=x:
			direction3=false
	else:
		$cloud3.position.x-=2
		if $cloud3.position.x<=0:
			direction3=true
			
	if direction1:
		$cloud1.position.x+=1.5
		if $cloud1.position.x>=x:
			direction1=false
	else:
		$cloud1.position.x-=1.5
		if $cloud1.position.x<=0:
			direction1=true	
			
	if direction2:
		$cloud2.position.x+=2
		if $cloud2.position.x>=x:
			direction2=false
	else:
		$cloud2.position.x-=2
		if $cloud2.position.x<=0:
			direction2=true			
			
	


	


