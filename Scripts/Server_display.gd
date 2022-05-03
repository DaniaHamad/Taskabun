#extends Area2D
extends Control
var ip_address = ""
var server_info
func _on_Join_button_pressed():
	Network.ip_address = ip_address
	Network.join_server()
	get_parent().get_parent().queue_free()


func set_name(x):
	$name.text=x

func set_number(x,y):
	var c=str(x)+"/"+str(y)
	$number.text=c
	

func _on_Timer_timeout():
	var x=str(server_info.current_players)
	var y=str(server_info.number_of_players)
	set_number(x,y)
	if x==y or Network.allow_join==false:
		queue_free()
