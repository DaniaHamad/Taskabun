extends Control


var player = load("res://Player/Player.tscn")
var scorePlayer = load("res://Game/ScoreBoardSystem.tscn")
var current_spawn_location_instance_number = 1
var player_char=-1
var current_player_for_spawn_location_number = null
var ovalLoc=190/5
var my_Id=-1

onready var multiplayer_config_ui = $Multiplayer_configure
onready var username_text_edit = $Multiplayer_configure/Username_text_edit
onready var device_ip_address = $UI/Device_ip_address
onready var start_game = $UI/Start_game
onready var master_ready = $Spawn_locations/MasterReady
onready var chars_list=$Multiplayer_configure/Charecters


func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	start_game.hide()
	

	device_ip_address.text = Network.ip_address
	
	if get_tree().network_peer != null:
		
		current_spawn_location_instance_number = 1
			
					
						
	if get_tree().network_peer != null:
		if get_tree().is_network_server():
			chars_list.select(0)
			_on_Charecters_item_selected(0)
			player_char=1
			$Spawn_locations/MasterReady.show()
			$Spawn_locations/Ready.hide()
		else:
			$Spawn_locations/MasterReady.hide()	
			$Spawn_locations/Ready.show()
			
			




func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")		
	instance_player(id)




func _player_disconnected(id) -> void:
	rpc("remove_player",id)

		
sync func remove_player(id):
	if Persistent_nodes.has_node(str(id)):
		Persistent_nodes.get_node(str(id)).username_text_instance.queue_free()
		Persistent_nodes.get_node(str(id)).queue_free()	
		Persistent_nodes.get_node("CanvasLayer").get_node(str(id)).queue_free()
	yield(get_tree().create_timer(.7),"timeout")	
	var c=1	
	for player in Persistent_nodes.get_children():
		if player.is_in_group("Player"):
			var location=get_node("Spawn_locations/" + str(c)).global_position
			location.y-=150/5
			player.rpc("update_position", location)	
			c+=1
	#for playerscore in Persistent_nodes.get_node("CanvasLayer").get_children():
	#	if playerscore.is_in_group("Score"):
	#		playerscore.rpc("update_position", Vector2(playerscore.global_position.x-64,playerscore.global_position.y))	
	
	Network.No_of_current_players=c-1
			
		
		

func _on_MasterReady_pressed():
	if username_text_edit.text != "":				
		$Spawn_locations/MasterReady.hide()
		$Multiplayer_configure.hide()
		$Spawn_locations/oval.hide()
		start_game.show()
		my_Id=get_tree().get_network_unique_id()
		instance_player(my_Id)
		Global.instance_node(load("res://Scripts/Server_advertiser.tscn"), get_tree().current_scene)	
	else:
		$Popup/message.text="please enter a valid name"
		$Popup.popup() 	

func _on_Ready_pressed():
	if player_char==-1:
		show_popup2("please select a charecter")
	else:	
		if username_text_edit.text != "":
			var c=true
			for child in Persistent_nodes.get_children():
				if child.is_in_group("Username"):
					if child.text==username_text_edit.text:
						c=false
						break
			if c:
				$Spawn_locations/Ready.hide()
				$Spawn_locations/oval.hide()
				multiplayer_config_ui.hide()
				my_Id=get_tree().get_network_unique_id()
				instance_player(my_Id)
				
			else:
				$Popup/message.text="This name is taken ,please try another one"
				$Popup.popup() 	
		else:
			$Popup/message.text="please enter a valid name"
			$Popup.popup() 




func _connected_to_server() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	print("connect to server")
	for child in Persistent_nodes.get_children():
		if child.is_in_group("Player"):
			var x=child.get_mychar()
			if x=="res://Assets/players/body1.png":
				chars_list.set_item_disabled(0,true)
			elif x=="res://Assets/players/body2.png":
				chars_list.set_item_disabled(1,true)	
			elif x=="res://Assets/players/body3.png":
				chars_list.set_item_disabled(2,true)	
			elif x=="res://Assets/players/body4.png":
				chars_list.set_item_disabled(3,true)
	if current_spawn_location_instance_number==2:
		$Spawn_locations/Ready.rect_position=Vector2(634/5,850/5)	
		$Spawn_locations/oval.rect_position.x=534/5	
		ovalLoc=534/5
	if current_spawn_location_instance_number==3:
		$Spawn_locations/Ready.rect_position=Vector2(1004/5,850/5)	
		$Spawn_locations/oval.rect_position.x=920/5
		ovalLoc=920/5
	elif current_spawn_location_instance_number==4:
		$Spawn_locations/oval.rect_position.x=1304/5
		ovalLoc=1304/5
	
	$Multiplayer_configure.show()





func instance_player(id) -> void:
	var location=get_node("Spawn_locations/" + str(current_spawn_location_instance_number)).global_position
	location.y-=150/5
	var player_instance = Global.instance_node_at_location(player, Persistent_nodes, location)
	var score_instance = Global.instance_node_at_location(scorePlayer, Persistent_nodes.get_node("CanvasLayer"), 
	Vector2(
		32+((current_spawn_location_instance_number-1)*64),32
		)
		)
	score_instance.hide()
	player_instance.name = str(id)
	score_instance.name = str(id)
	
	player_instance.set_network_master(id)
	score_instance.set_network_master(id)
	
	player_instance.myOval="res://Assets/oval.png"
	
	
	player_instance.username = username_text_edit.text
	print(str(player_instance.username))
	score_instance.username = player_instance.username
	print(str(score_instance.username))
	score_instance.tile = 1
	var c="Spawn_locations/Sprite"+str(current_spawn_location_instance_number)
	
	player_instance.playerCount = current_spawn_location_instance_number
	
	get_node(c).hide()
	var s="res://Assets/players/body"+str(player_char)+".png"
	var s2 ="res://Assets/players/head"+str(player_char)+".png"
	player_instance.mychar=s
	player_instance.mycharhead=s2
	
	match player_instance.playerCount:
		1:
			score_instance.myRank = "1st"
		2:
			score_instance.myRank = "2nd"
		3:
			score_instance.myRank = "3rd"
		4:
			score_instance.myRank = "4th"
	
	var charSprite=player_instance.get_mychar()
	if charSprite=="res://Assets/players/body1.png":
		score_instance.mychar = "res://Assets/players/head1.png"
		score_instance.colorPlayer = Color("8BD7DC")#8BD7DC
	elif charSprite=="res://Assets/players/body2.png":
		score_instance.mychar = "res://Assets/players/head2.png"
		score_instance.colorPlayer = Color("479D2E")
	elif charSprite=="res://Assets/players/body3.png":
		score_instance.mychar = "res://Assets/players/head3.png"
		score_instance.colorPlayer = Color("CB3F43")#479D2E
	elif charSprite=="res://Assets/players/body4.png":
		score_instance.mychar = "res://Assets/players/head4.png"
		score_instance.colorPlayer = Color("DB9233")
	
	current_spawn_location_instance_number += 1
	#if get_tree().network_peer != null:
	#		if get_tree().is_network_server():
	#			Persistent_nodes.rpc("update_number_of_players",true)
	

func _on_Start_game_pressed():
	Network.allow_join=false
	rpc("switch_to_game")


sync func switch_to_game() -> void:
	for child in Persistent_nodes.get_children():
		if child.is_in_group("Player"):
			child.set_myOval("")
			child.get_node("oval").hide()
		elif child.is_in_group("Score"):
			child.show()
	print("moving to game")
	Persistent_nodes.get_node("background").queue_free()
	Persistent_nodes.get_node("TextureRect").queue_free()
	get_tree().change_scene("res://Game/Game.tscn")



func _on_Popup_ok_pressed():
	$Popup.hide()
	
func show_popup2(c):	
	$Popup2/Message.text=c
	$Popup2.popup()
	yield(get_tree().create_timer(2.0),"timeout")
	$Popup2.hide()	

onready var sprite1=$Spawn_locations/Sprite1
onready var sprite2=$Spawn_locations/Sprite2
onready var sprite3=$Spawn_locations/Sprite3
onready var sprite4=$Spawn_locations/Sprite4


	
			
			

func _on_Charecters_item_selected(index):
	if chars_list.is_item_disabled(index):
		show_popup2("This charecter is taken, please try another one.")
	else:	
		player_char=index+1
		var s="res://Assets/players/body"+str(player_char)+".png"	
			
		if current_spawn_location_instance_number==1:	
			sprite1.texture=load(s)
		if current_spawn_location_instance_number==2:
			sprite2.texture=load(s)	
		if current_spawn_location_instance_number==3:
			sprite3.texture=load(s)		
		if current_spawn_location_instance_number==4:
			sprite4.texture=load(s)		



func _on_LeaveButton_pressed():
	if get_tree().network_peer != null:
		if get_tree().is_network_server():
			rpc("leave_game")
		else:
			if my_Id==-1:
				get_tree().change_scene("res://UI/Main.tscn")
			else:	
				rpc("remove_player",my_Id)
				for child in Persistent_nodes.get_children():
					if child.is_in_group("Net"):
						child.queue_free()
				get_tree().change_scene("res://UI/Main.tscn")		


		


sync func leave_game() -> void:
	show_popup2("Game Ended back to Main")
	yield(get_tree().create_timer(.5),"timeout")
	Network._server_disconnected()
	Network.reset_network_connection()
	for child in Persistent_nodes.get_children():
					if child.is_in_group("Net"):
						child.queue_free()
	get_tree().change_scene("res://UI/Main.tscn")	
			
