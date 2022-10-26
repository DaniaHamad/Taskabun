extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal opened
signal closed

# Called when the node enters the scene tree for the first time.
func open_and_start():
	hide()
	yield(get_tree().create_timer(.2),"timeout")
	$AnimatedSprite.play("open")
	show()
	yield(get_tree().create_timer(.4),"timeout")
	$AnimatedSprite.play("default")
	emit_signal("opened")
	
func close_and_end():
	$AnimatedSprite.play("close")
	yield(get_tree().create_timer(.3),"timeout")
	hide()
	emit_signal("closed")	
	
