extends Control

##this is server_browser
onready var server_listener = $Server_listener
onready var server_ip_text_edit = $ManualControl/server_ip_text_edit
onready var server_container = $LocalControl/VBoxContainer
onready var manual_setup_button = $window/Manual_setup
onready var servers_list=$LocalControl/ItemList
func _ready() -> void:
	$ManualControl.hide()
	


func _on_Server_listener_new_server(serverInfo):	
	var server_node = Global.instance_node(load("res://Scripts/Server_display.tscn"), server_container)
	server_node.set_name( "%s - %s" % [serverInfo.ip, serverInfo.name])
	server_node.server_info=serverInfo
	server_node.ip_address = str(serverInfo.ip)

func _on_Server_listener_remove_server(serverIp):
	for serverNode in server_container.get_children():
		if serverNode.is_in_group("Server_display"):
			if serverNode.ip_address == serverIp:
				serverNode.queue_free()
				break

func _on_Manual_setup_pressed():
	Music.play_BtnFX()
	$window/ManualColor.color="#0c0096"
	$window/LocalColor.color="#0c0050"
	$LocalControl.hide()
	$ManualControl.show()
	server_ip_text_edit.call_deferred("grab_focus")
	

func _on_Join_server_pressed():
	Music.play_BtnFX()
	Network.ip_address = server_ip_text_edit.text
	hide()
	Network.join_server()
	


func _on_BackButton_pressed():
	Music.play_BtnFX()
	get_tree().change_scene("res://UI/Main.tscn")


func _on_Local_pressed():
	Music.play_BtnFX()
	$window/LocalColor.color="#0c0096"
	$window/ManualColor.color="#0c0050"
	$ManualControl.hide()
	$LocalControl.show()
