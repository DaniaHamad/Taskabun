extends Area2D
onready var animatedSprit=$AnimatedSprite
#onready var parent=get_tree().get_root().get_node("world")
var coin=false

func enable_click(x):
	if x:
		$ReferenceRect.show()
	else:
		$ReferenceRect.hide()	


func _ready():
	$AnimatedSprite.play("cupIdle")

sync func on_click(duration):
	$AnimatedSprite.play("cupUp")	
	yield(get_tree().create_timer(duration),"timeout")
	$AnimatedSprite.play("cupDown")
		

func show_coin():
	$AnimatedSprite.play("cupWin")	
			

sync func show_win():
	$AnimatedSprite.play("cupIdle")
	$AnimatedSprite.play("cupWin")
	

func _on_ReferenceRect_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		if coin:
			rpc("show_win")	
			get_parent().get_parent().rpc("stop_timer",true)
		else:
			rpc("on_click",.3)
			get_parent().get_parent().rpc("stop_timer",false)
