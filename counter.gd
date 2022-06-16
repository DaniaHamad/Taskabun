extends Node2D

export var duration=5
onready var timer=$Timer
func _ready():
	$Label.hide()

func start_timer(x):
	duration=x
	$Label.text=str(duration)	
	$Label.show()
	timer.start()
	
func stop_timer():
	timer.stop()
	$Label.hide()	

signal timeIsDone
func _on_Timer_timeout():
	duration-=1
	if duration<0:
		timer.stop()
		$Label.hide()
		emit_signal("timeIsDone")
	else:
		$Label.text=str(duration)
		
		
			
