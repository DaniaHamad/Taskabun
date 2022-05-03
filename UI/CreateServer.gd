extends Control

#set_refuse_new_network_connections(false) to stop accepting join requests
var No_of_players=2
var GameTheme="Park"
var GameName=""
var serversList=[]


func _ready():
	$control.hide()
	$YSort/glowing.open_and_start()
	
	
	
	
func _on_glowing_opened():
	$control.show()	
		
func _on_BackButton_pressed():
	get_tree().change_scene("res://UI/Main.tscn")


func _on_No2_pressed():
	$control/No3.pressed=false
	$control/No4.pressed=false
	No_of_players=2


func _on_No3_pressed():
	$control/No2.pressed=false
	$control/No4.pressed=false
	No_of_players=3


func _on_No4_pressed():
	$control/No3.pressed=false
	$control/No2.pressed=false
	No_of_players=4


func _on_Create_pressed():
	var val=$control/GameName.text.replace(" ","")
	if val!="" and val.length()>3 and val.length()<25:
		GameName=$control/GameName.text
		var c=-1;
		if c==-1:
			$control.hide()
			$YSort/glowing.close_and_end()
		else:
			show_popup("Game name already taken , please try another name")	
	else:
		show_popup("Plaese Enter A Valid Game Name")
		


func _on_glowing_closed():
	GameName=$control/GameName.text
	Network.current_player_username = GameName
	Network.No_of_players=No_of_players
	Network.create_server()
	
		
	
func show_popup(x):
	$Popup/message.text=x
	$control.hide()
	$YSort/glowing.hide()
	$Popup.popup() 


func _on_Popup_ok_pressed():
	$Popup.hide()
	$YSort/glowing.show()
	$control.show()




