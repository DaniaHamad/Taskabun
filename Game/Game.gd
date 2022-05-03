extends Node2D
onready var players = $YSortWorld/Players


var scoreSystem = load("res://Game/ScoreBoardSystem.tscn")
var numberOfPlayers=0

var Oddrow = true

onready var tasks =  $Tasks

onready var camera = $Camera2D
onready var diceAllPlayers = $CanvasLayer/DiceAllPlayers
onready var yourTurn = $CanvasLayer/YourTurn
onready var snakes = $YSortWorld/Snakes

var player #we are the current player
var rolls=0 

var greenWayEmptyTilePos=[
	[96.0,-32.0],
	[416.0,-32.0],
	[544.0,-32.0],
	[608.0,-96.0],
	[544.0,-96.0],
	[288.0,-96.0],
	[160.0,-96],
	[96.0,-96.0],
	[32.0,-160.0],
	[352.0,-160.0],
	[480.0,-160.0],
	[608.0,-160.0],
	[544.0,-224.0],
	[480.0,-224.0],
	[416.0,-224.0],
	[160.0,-224.0],
	[96.0,-224.0],
]
var yellowWayEmptyTilePos=[
	[160.0 , -288.0],
	[288.0 , -288.0],
	[480.0, -288.0],
	[608.0 , -288.0],
	[416.0 , -352.0],
	[288.0, -352.0],
	[96.0, -352.0],
	[32.0, -352.0],
	[288.0, -416.0],
	[416.0 , -416.0],
	[608.0 , -416.0],
	[608.0 , -480.0],
	[480.0 , -480.0],
	[352.0 , -480.0],
	[224.0 , -480.0],
	[32.0 , -480.0],
	[160.0 , -544.0],
	[416.0 , -544.0],
	[480.0 , -544.0],
	[544.0 , -544.0],
]
var redWayEmptyTilePos=[
	[608.0 , -608.0],
	[480.0 , -608.0],
	[352.0,  -608.0],
	[96.0,-608.0],
]

var greenTaskPos=[]
var yellowTaskPos=[]
var redTaskPos=[]

var playersEmptyPos=[]

func _ready():
	randomize()
	var speed = 0.006 #camera speed
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected") #to remove player
	instance_player(get_tree().get_network_unique_id()) #player and score enter game
	rpc("move_Children") #from persistent_node to ysort players
	store_Tile_Pos()
	#yield(move_camera(speed),"completed")#move the camera until it's completed
	player = players.get_node(str(get_tree().get_network_unique_id())) #we are the current player (this is me)


	var i=0
	while(numberOfPlayers>i):#function to show all the dices only on the DiceAllPlayers scene
		i+=1
		var dice= diceAllPlayers.get_node(str("Dice"+str(i))) #call the scene DiceAllPlayers and 
		dice.diceId=i
		playersEmptyPos.append([0.0,0.0])
		dice.show()


	var r = player.playerCount #show the button for me only (current player)
	var roll= diceAllPlayers.get_node("Roll"+str(r)) #get the button roll for me
	roll.show()
	rpc("hide_Score")
	diceAllPlayers.show()

func _player_disconnected(id) -> void:
	rpc("remove_player",id)
sync func remove_player(id):
	if Persistent_nodes.get_node("CanvasLayer").has_node(str(id)):
		Persistent_nodes.get_node("CanvasLayer").get_node(str(id)).queue_free()
	if players.has_node(str(id)):
		players.get_node(str(id)).username_text_instance.queue_free()
		players.get_node(str(id)).queue_free()
	yield(get_tree().create_timer(.7),"timeout")	
	#var c=1	
	#for playerscore in Persistent_nodes.get_node("CanvasLayer").get_children():
		#if playerscore.is_in_group("Score"):
		#	playerscore.rpc("update_position", Vector2(playerscore.global_position.x-64,playerscore.global_position.y))	
			#c+=1
	#Network.No_of_current_players=c-1

func instance_player(id) -> void:
	for child in Persistent_nodes.get_children(): #location of the players
		if child.is_in_group("Player"):
			if child.name == str(id):
				child.global_position =  Vector2(32,-32) #first tile location

		else:# not a player is it a score?
			for scoreChild in Persistent_nodes.get_node("CanvasLayer").get_children():
				if scoreChild.is_in_group("Score"):
					if scoreChild.name == str(id):#set the score position
						scoreChild.global_position =  Vector2(
							32+
							((Persistent_nodes.get_node(str(id)).playerCount-1)*64)
							,32)
						#scoreChild.show()
	rpc("show_Score")
sync func show_Score():
	for child in Persistent_nodes.get_node("CanvasLayer").get_children():
		if child.is_in_group("Score"):
			child.show()
			
sync func hide_Score():
	for child in Persistent_nodes.get_node("CanvasLayer").get_children():
		if child.is_in_group("Score"):
			child.hide()


sync func move_Children():
	for child in Persistent_nodes.get_children():
		if child.is_in_group("Player"):
			Persistent_nodes.remove_child(child)
			players.add_child(child)
			numberOfPlayers+=1
			var followPlayer = RemoteTransform2D.new()
			followPlayer.name = "follow"
			child.add_child(followPlayer)
	#players.get_node(str(1)).get_node("follow").set_remote_node($Camera2D.get_path())



func move_camera(delta):
	var originalPosition = -44
	var endPosition = -598
	var speed = 0
	while(camera.position.y!=endPosition):
		speed+=delta
		camera.global_position = lerp(camera.global_position, Vector2(-90,endPosition), speed)
		yield(get_tree().create_timer(.1),"timeout")


#	yield(get_tree().create_timer(.7),"timeout")
	speed=0
	while(camera.position.y!=originalPosition):
		speed+=delta
		camera.global_position = lerp(camera.global_position,Vector2(-90,originalPosition) , speed)
		yield(get_tree().create_timer(.1),"timeout")

	#yield(get_tree().create_timer(.3),"timeout")
	yield(get_tree(), "idle_frame")



func _on_Roll1_pressed():
	var diceNum = randi()%6+1
	rpc("show_dice",1,diceNum)


func _on_Roll2_pressed():
	var diceNum = randi()%6+1
	rpc("show_dice",2,diceNum)


func _on_Roll3_pressed():
	var diceNum = randi()%6+1
	rpc("show_dice",3,diceNum)#show every body including me my dice


func _on_Roll4_pressed():
	var diceNum = randi()%6+1
	rpc("show_dice",4,diceNum)

sync func show_dice(diceId,diceNum):#show every body including me my dice
	var dublicate = false
	var diceHolder = diceAllPlayers.get_node("Dice"+str(diceId)) #get my dice
	diceHolder.texture=load("res://Assets/Dice/"+str(diceNum)+".png") #change my dice texture
	diceHolder.diceValue = diceNum
	var roll = diceAllPlayers.get_node("Roll"+str(diceId)) #get my roll button
	for i in range(numberOfPlayers+1):#start from zero to numberOfPlayers
		var dice= diceAllPlayers.get_node(str("Dice"+str(i+1)))
		if dice.texture.resource_path == "res://Assets/Dice/"+str(diceNum)+".png" && dice.diceId!=diceId&&player.playerCount==diceId:
			#if the other dice is qual to my dice && the dice is not mine && I'm the owner of this dice that has been dublicated with
			rpc("show_Roll_Button_Puppet",dice.diceId) #make the other dice roll again
			dublicate=true

	if dublicate:
		if player.playerCount == diceId:
			roll.show()
	else:
		if player.playerCount == diceId:
			roll.hide()
			rpc("i_rolled")
			dublicate=false

	if(rolls==numberOfPlayers):#every body rolls without any dublicate 
		rpc("the_order")#show the results

sync func show_Roll_Button_Puppet(playerId):
	if player.playerCount==playerId:
		var roll2 = diceAllPlayers.get_node("Roll"+str(playerId))
		roll2.show()
		rpc("i_unrolled")

sync func i_rolled():
	rolls+=1
sync func i_unrolled():
	if rolls -1>=0:
		rolls-=1

sync func the_order():
	for i in range(numberOfPlayers+1):
		i+=1
		var dice = diceAllPlayers.get_node(str("Dice"+str(i)))#get the player's dice
		for playery in players.get_children():
			if playery.is_in_group("Player"):
				if playery.playerCount==dice.diceId:#if the player is the owner of this dice
					var playerDice = [playery,int(dice.diceValue)]
					PlayersTurns.add_player_to_Array_to_get_sorted(playerDice)#add the player with their dice to an array
					break
	PlayersTurns.sort_players_Turns_desc()# sort all the added players
	for i in range(numberOfPlayers):
		i+=1
		var playerHolder = PlayersTurns.get_player_turn_now()
		var namePlayerPopUp = diceAllPlayers.get_node(str("Name"+str(playerHolder.playerCount)))
		namePlayerPopUp.text = str(playerHolder.username)
		namePlayerPopUp.show()
		var rankPlayerPopUp = diceAllPlayers.get_node(str("Rank"+str(playerHolder.playerCount)))
		match i:
			1:
				rankPlayerPopUp.text = "1st"
			2:
				rankPlayerPopUp.text = "2nd"
			3:
				rankPlayerPopUp.text = "3rd"
			4:
				rankPlayerPopUp.text ="4th"
		rankPlayerPopUp.show()
	diceAllPlayers.get_node("Label").text = "The order!"
	PlayersTurns.modify_player_tile(player)
	yield(get_tree().create_timer(3),"timeout")
	diceAllPlayers.queue_free()
	player_turn()#move forward with the game

sync func player_turn():
	rpc("hide_Score")
	var playerHolder = PlayersTurns.get_player_turn_now()
	for child in players.get_children():
		if child.is_in_group("Player"):
			child.get_node("follow").set_remote_node("")#remove all the camera from all the players
	playerHolder.get_node("follow").set_remote_node(camera.get_path()) #give the camera to the current player
	yourTurn.get_node("NameTurn").text = str(playerHolder.username+"\'s turn!")
	yourTurn.get_node("Move").text = "Roll the Dice!"
	var diceHolder =yourTurn.get_node("Dice")
	yourTurn.get_node("RollButton").hide()
	diceHolder.diceValue = 0
	diceHolder.texture=load("res://Assets/Dice/"+str(0)+".png")
	if(player.username == playerHolder.username):
		yourTurn.get_node("RollButton").show()
	yourTurn.show()


func _on_RollButton_pressed():
	var diceNum = randi()%6+1
	#print(str(player.name))
	rpc("move_dice_message",str(player.name),diceNum)
	

sync func move_dice_message(playerToMoveName,diceNum):
	var diceHolder =yourTurn.get_node("Dice")
	diceHolder.diceValue = diceNum
	diceHolder.texture=load("res://Assets/Dice/"+str(diceNum)+".png")
	if(diceNum!=1):
		yourTurn.get_node("Move").text = "Move "+str(diceNum) +" steps!"
	else:
		yourTurn.get_node("Move").text = "Move "+str(diceNum) +" step!"
	yourTurn.get_node("RollButton").hide()
	yield(get_tree().create_timer(3),"timeout")
	yourTurn.hide()
	rpc("show_Score")
	player.get_node("follow").set_remote_node("")
	var playerToMove = players.get_node(str(playerToMoveName))
	playerToMove.get_node("follow").set_remote_node(camera.get_path())#give the player the camera
	if player.name == str(playerToMoveName):
		move_player(str(playerToMoveName),diceNum)

func move_player(playerToMoveName,diceNum):
	match where_Is_The_Player_Standing(playerToMoveName):
		"green":
			rpc("add_empty_tile_pos",playerToMoveName,"green")
		"yellow":
			rpc("add_empty_tile_pos",playerToMoveName,"yellow")
		"red" :
			rpc("add_empty_tile_pos",playerToMoveName,"red")

	
	rpc("show_Score")
	yield(get_tree().create_timer(2),"timeout")
	var playerToMove = players.get_node(str(playerToMoveName)) #bring me the player
	var onTile #the tile the player is on
	var scoreHolder# bring the player's score
	for score in Persistent_nodes.get_node("CanvasLayer").get_children():
		if(score.is_in_group("Score")):
			if score.get_node("PlayerName").text==playerToMove.username:
				scoreHolder = score 
				break
	onTile = int(scoreHolder.get_node("TileNumber").text)
	if onTile ==100:
		rpc("player_turn")
		return 
	var goalTile = onTile+diceNum
	if goalTile >100:
		goalTile =100
	var hopTile = onTile
	var movement = 64
	if !Oddrow:
		movement*=-1
	var calculateMove = playerToMove.position.x
	while(hopTile!=goalTile):
		calculateMove+=movement
		if calculateMove>625:#odd is true then go up be false
			playerToMove.position.y -=movement
			calculateMove = playerToMove.position.x
			movement*=-1
			Oddrow=false  
		elif calculateMove<10:#odd is false then go up be true
			playerToMove.position.y +=movement
			calculateMove = playerToMove.position.x
			movement*=-1 
			Oddrow=true 
		else:
			playerToMove.position.x +=movement
			calculateMove = playerToMove.position.x
		hopTile+=1
		scoreHolder.tile = hopTile
		scoreHolder.get_node("TileNumber").text = str(hopTile)
		yield(get_tree().create_timer(1),"timeout")
	rpc("refresh_ranking",str(playerToMoveName)) #rpc sync
	yield(get_tree().create_timer(3),"timeout")
	match where_Is_The_Player_Standing(playerToMoveName):
		"green":
			rpc("pop_empty_tile_pos",playerToMoveName,"green")
		"yellow":
			rpc("pop_empty_tile_pos",playerToMoveName,"yellow")
		"red" :
			rpc("pop_empty_tile_pos",playerToMoveName,"red")
	yield(get_tree().create_timer(3),"timeout")
	rpc("move_snakes",randi()%greenWayEmptyTilePos.size(),randi()%yellowWayEmptyTilePos.size(),randi()%redWayEmptyTilePos.size())
	yield(get_tree().create_timer(3),"timeout")
	rpc("player_turn")

sync func refresh_ranking(playerToMoveName):
	print("Entered refresh_ranking")
	var playerToMove = players.get_node(str(playerToMoveName))
	PlayersTurns.modify_player_tile(playerToMove)
	PlayersTurns.sort_players_Ranking_desc()
	for i in range(numberOfPlayers):
		var playerHolder = PlayersTurns.get_player_rank_now()
		var scorePlayerHolder = Persistent_nodes.get_node("CanvasLayer").get_node(str(playerHolder.name))
		match i+1:
			1:
				scorePlayerHolder.myRank = "1st"
			2:
				scorePlayerHolder.myRank = "2nd"
			3:
				scorePlayerHolder.myRank = "3rd"
			4:
				scorePlayerHolder.myRank = "4th"
	playerToMove.get_node("follow").set_remote_node("")

func store_Tile_Pos():
	
	var tempTaskPos
	for taskGroup in tasks.get_children():
		for taskIndv in taskGroup.get_children():
			if taskIndv.is_in_group("Task"):
				if taskIndv.task=="green":
					tempTaskPos = [taskIndv.position.x,taskIndv.position.y]
					greenTaskPos.append(tempTaskPos)
				elif taskIndv.task =="yellow":
					tempTaskPos = [taskIndv.position.x,taskIndv.position.y]
					yellowTaskPos.append(tempTaskPos)
				else:
					tempTaskPos = [taskIndv.position.x,taskIndv.position.y]
					redTaskPos.append(tempTaskPos)

func where_Is_The_Player_Standing(playerHasMovedName):
	
	print("Entered where_Is_The_Player_Standing")
	var temp = [player.position.x,player.position.y]
	print (temp)
	for i in snakes.get_children():
		if i.is_in_group("Snake"):
			if player.position.x == i.position.x&&player.position.y==i.position.y:
				playersEmptyPos[player.playerCount-1] = temp
				print("collided with "+i.name)
				return i.name

	if greenTaskPos.has(temp):
		print("Player has been collided with a green task ")

		return "greenTask"
	if yellowTaskPos.has(temp):
		print("Player has been collided with a yellow task ")
		return "yellowTask"
	
	if redTaskPos.has(temp):
		print("Player has been collided with a red task ")
		return "RedTask"
	print("Player is on empty tile")
	return check_if_on_empty_tile(playerHasMovedName)
	

sync func add_empty_tile_pos(playerHasMovedName,wayType):
	var playerHasMoved = players.get_node(str(playerHasMovedName))
	var temp = [playerHasMoved.position.x,playerHasMoved.position.y]#old pos
	playersEmptyPos[playerHasMoved.playerCount-1]=0
	match wayType:
		"green":
			greenWayEmptyTilePos.append(temp)
		"yellow":
			yellowWayEmptyTilePos.append(temp)
		"red":
			redWayEmptyTilePos.append(temp)
	print(str(temp)+" has been added to "+wayType+" arrayEmpty")

sync func pop_empty_tile_pos(playerHasMovedName,wayType):
	var playerHasMoved = players.get_node(str(playerHasMovedName))#new
	playersEmptyPos[playerHasMoved.playerCount-1]=[playerHasMoved.position.x,playerHasMoved.position.y]
	match wayType:
		"green":
			greenWayEmptyTilePos.remove(greenWayEmptyTilePos.find(playersEmptyPos[playerHasMoved.playerCount-1]))
			
		"yellow":
			yellowWayEmptyTilePos.remove(yellowWayEmptyTilePos.find(playersEmptyPos[playerHasMoved.playerCount-1]))
		"red":
			redWayEmptyTilePos.remove(redWayEmptyTilePos.find(playersEmptyPos[playerHasMoved.playerCount-1]))
	print(str(player.position)+" has been deleted from "+wayType+" arrayEmpty")

func check_if_on_empty_tile(playerMove):
	var playerHasMoved = players.get_node(str(playerMove))
	playersEmptyPos[playerHasMoved.playerCount-1]=[playerHasMoved.position.x,playerHasMoved.position.y]
	var temp = playersEmptyPos[playerHasMoved.playerCount-1]
	print(str(temp))
	if (temp[0]!=32||temp[1]!=-32)&&(temp[0]!=32||temp[1]!=-608):
		
		if temp[1]<=-32.0&&temp[1]>=-224.0:
			print("Player has been is on an empty green way tile")
			return "green"
		elif temp[1]<=-288.0&&temp[1]>=-544.0:
			print("Player has been is on an empty yellow way tile")
			return "yellow"
		elif temp[1]==-608:
			print("Player has been is on an empty red way tile")
			return "red"
		
	print("non")
	return null





sync func move_snakes(randGreen,randYellow,randRed):
	print("entered move_snakes")
	var snakePos = []
	var newPos=[]
	var rand
	for snake in snakes.get_children():
		if snake.is_in_group("Snake"):
			snakePos = [snake.position.x,snake.position.y]
			if snake.is_in_group("Green"):
				rand = randGreen
				snake.position.x = greenWayEmptyTilePos[rand][0]
				snake.position.y = greenWayEmptyTilePos[rand][1]
				greenWayEmptyTilePos.remove(greenWayEmptyTilePos.find([snake.position.x,snake.position.y]))
				if !playersEmptyPos.has([snake.position.x,snake.position.y]):
					greenWayEmptyTilePos.append(snakePos)
			elif snake.is_in_group("Yellow"):
				rand = randYellow
				snake.position.x = yellowWayEmptyTilePos[rand][0]
				snake.position.y = yellowWayEmptyTilePos[rand][1]
				yellowWayEmptyTilePos.remove(yellowWayEmptyTilePos.find([snake.position.x,snake.position.y]))
				if !playersEmptyPos.has([snake.position.x,snake.position.y]):
					yellowWayEmptyTilePos.append(snakePos)
			elif snake.is_in_group("Red"):
				rand=randRed
				snake.position.x = redWayEmptyTilePos[rand][0]
				snake.position.y = redWayEmptyTilePos[rand][1]
				redWayEmptyTilePos.remove(redWayEmptyTilePos.find([snake.position.x,snake.position.y]))
				if !playersEmptyPos.has([snake.position.x,snake.position.y]):
					redWayEmptyTilePos.append(snakePos)
	yield(get_tree().create_timer(3),"timeout")

