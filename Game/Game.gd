extends Node2D
onready var players = $YSortWorld/Players


var scoreSystem = load("res://Game/ScoreBoardSystem.tscn")
var numberOfPlayers=0

var Oddrow = true
var backwards = false
var triggerIt = true
var bossSnakeGoBackwords = false
onready var tasks =  $Tasks
onready var emptyTiles = $EmptyTiles
onready var camera = $Camera2D
onready var diceAllPlayers = $CanvasLayer/DiceAllPlayers
onready var yourTurn = $CanvasLayer/YourTurn
onready var snakeBattlePopUp = $CanvasLayer/SnakeBattlePopUp
onready var snakeBattleResult = $CanvasLayer/SnakeBattleResult
onready var snakes = $YSortWorld/Snakes
onready var canvas = $CanvasLayer
onready var lastTilePopup =$CanvasLayer/LastTilePopUp 
onready var playersRanks = $CanvasLayer/PlayersRanks

var player #we are the current player
var rolls=0 

var snakeCollidedWith
var taskCollidedWith

var clearedTask=false
var clearedSnake=false

var greenWayEmptyTilePos=[]
var yellowWayEmptyTilePos=[]
var redWayEmptyTilePos=[]

var greenTaskPos=[]
var yellowTaskPos=[]
var redTaskPos=[]

var playersEmptyPos=[]

var map_data
var firstTile= []
var lastTile=[]
var boundaryLeft
var boundaryRight
var mapMovement 
var mapGoal
var hopNumTile
var greenArea = []
var yellowArea = []
var redArea =[]


func _ready():
	randomize()
	var speed = 0.006 #camera speed
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected") #to remove player
	instance_player(get_tree().get_network_unique_id()) #player and score enter game
	rpc("move_Children") #from persistent_node to ysort players
	store_Tile_Pos()
	store_Empty_Pos()
	get_map_config()
	yield(move_camera(speed),"completed")#move the camera until it's completed
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



func move_camera(delta):
	var originalPosition = -44
	var endPosition = -598
	var speed = 0
	while(camera.position.y!=endPosition):
		speed+=delta
		camera.global_position = lerp(camera.global_position, Vector2(-90,endPosition), speed)
		yield(get_tree().create_timer(.1),"timeout")


	speed=0
	while(camera.position.y!=originalPosition):
		speed+=delta
		camera.global_position = lerp(camera.global_position,Vector2(-90,originalPosition) , speed)
		yield(get_tree().create_timer(.1),"timeout")

	yield(get_tree(), "idle_frame")


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

func store_Empty_Pos():
	var emptyPos
	for empty in emptyTiles.get_children():
		for childEmpty in empty.get_children():
			if childEmpty.is_in_group("EmptyGreen"):
				emptyPos = [childEmpty.position.x,childEmpty.position.y]
				greenWayEmptyTilePos.append(emptyPos)
			elif childEmpty.is_in_group("EmptyYellow"):
				emptyPos = [childEmpty.position.x,childEmpty.position.y]
				yellowWayEmptyTilePos.append(emptyPos)
			else:
				emptyPos = [childEmpty.position.x,childEmpty.position.y]
				redWayEmptyTilePos.append(emptyPos)

func get_map_config():
	var mapData_file= File.new()
	mapData_file.open ( "res://Data/MapData.json" , File.READ )
	var mapDatajson= JSON.parse ( mapData_file.get_as_text())
	
	map_data=mapDatajson.result



	firstTile = map_data[name]["firstTile"]
	lastTile = map_data[name]["lastTile"]
	mapMovement = map_data[name]["mapMovement"]
	boundaryRight= map_data[name]["boundaryRight"]
	boundaryLeft = map_data[name]["boundaryLeft"]
	mapGoal = map_data[name]["mapGoal"]
	hopNumTile =map_data[name]["hopNumTile"]
	greenArea = map_data[name]["greenArea"]
	yellowArea = map_data[name]["yellowArea"]
	redArea = map_data[name]["redArea"]
	mapData_file.close()


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
	player_turn("",0)#move forward with the game

sync func player_turn(playerName,task):
	
	rpc("hide_Score")
	var playerHolder
	if task:
		playerHolder = players.get_node(playerName)
	else:
		playerHolder = PlayersTurns.get_player_turn_now()
	for child in players.get_children():
		if child.is_in_group("Player"):
			child.get_node("follow").set_remote_node("")#remove all the camera from all the players
	playerHolder.get_node("follow").set_remote_node(camera.get_path()) #give the camera to the current player
	if task:
		yourTurn.get_node("NameTurn").text = str(playerHolder.username+" beat the task!")
	else:
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
	yield(get_tree().create_timer(1),"timeout")
	var playerToMove = players.get_node(str(playerToMoveName)) #bring me the player
	playerToMove.get_node("follow").set_remote_node(camera.get_path())#give the player the camera
	var onTile #the tile the player is on
	var scoreHolder# bring the player's score
	for score in Persistent_nodes.get_node("CanvasLayer").get_children():
		if(score.is_in_group("Score")):
			if score.get_node("PlayerName").text==playerToMove.username:
				scoreHolder = score 
				break
	onTile = int(scoreHolder.get_node("TileNumber").text)

	if onTile ==mapGoal&&!bossSnakeGoBackwords:
		last_tile(player.name)
		return 

	var hopTile = onTile
	hopNumTile = map_data[name]["hopNumTile"]
	var movement = mapMovement
	if !Oddrow:
		movement*=-1
	
	if backwards:
		movement*=-1
		hopNumTile*=-1
		diceNum*=-1
	
	var goalTile = onTile+diceNum
	if goalTile >mapGoal:
		goalTile =mapGoal
	elif goalTile<1:
		goalTile=1
	print("goal Tile "+ str(goalTile))
	print("hope tile "+ str(hopTile))

	var calculateMove = playerToMove.position.x
	while(hopTile!=goalTile):
		calculateMove+=movement
		#print("calculateMove = "+ str(calculateMove))
		if calculateMove>boundaryRight:#odd is true then go up be false
	#		print("#odd is true then go down be false")
			if !backwards:
				playerToMove.position.y -=movement
				Oddrow=false
			else:
				playerToMove.position.y +=movement
				Oddrow=true
			calculateMove = playerToMove.position.x
			movement*=-1
			  
			backwards = false
			
		elif calculateMove<boundaryLeft:#odd is false then go up be true
	#		print("#odd is false then go down be true")
			if !backwards:
				playerToMove.position.y +=movement
				Oddrow=true 
			else:
				playerToMove.position.y -=movement
				Oddrow=false 
			calculateMove = playerToMove.position.x
			movement*=-1 
			
		else:
			playerToMove.position.x +=movement
			calculateMove = playerToMove.position.x
		hopTile+=hopNumTile
		scoreHolder.tile = hopTile
		scoreHolder.get_node("TileNumber").text = str(hopTile)
		yield(get_tree().create_timer(1),"timeout")
	backwards=false
	rpc("refresh_ranking",str(playerToMoveName)) #rpc sync
	yield(get_tree().create_timer(1),"timeout")
	if hopTile ==mapGoal:
		last_tile(player.name)
		return
	match where_Is_The_Player_Standing(playerToMoveName):
		"green":
			rpc("pop_empty_tile_pos",playerToMoveName,"green")
			loopTurns()
		"yellow":
			rpc("pop_empty_tile_pos",playerToMoveName,"yellow")
			loopTurns()
		"red" :
			rpc("pop_empty_tile_pos",playerToMoveName,"red")
			loopTurns()
		"Snake":
			rpc("Show_SnakeBattlePopUp",playerToMoveName,snakeCollidedWith)
		"easy":
			if triggerIt:
				$TasksLayer.select_task("easy")
			else:
				loopTurns()
		"medium":
			if triggerIt:
				$TasksLayer.select_task("medium")
			else:
				loopTurns()
		"hard":
			if triggerIt:
				$TasksLayer.select_task("hard")
			else:
				loopTurns()
		_:
			loopTurns()
	triggerIt=true
func loopTurns():
	yield(get_tree().create_timer(1),"timeout")
	var rand = randi()
	while rand==0:
		rand = randi()
	
	var randG
	var randY
	var randR
	if greenWayEmptyTilePos.size()<=0:
		randG = 0
	else:
		randG=rand%greenWayEmptyTilePos.size()
	if yellowWayEmptyTilePos.size()<=0:
		randY=0
	else:
		randY = (rand%yellowWayEmptyTilePos.size())
	if redWayEmptyTilePos.size()<=0:
		randR=0
	else:
		randR = (rand%redWayEmptyTilePos.size())
	
	rpc("move_snakes",randG,randY,randR)
	yield(get_tree().create_timer(1),"timeout")
	rpc("player_turn","",0)

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


func where_Is_The_Player_Standing(playerHasMovedName):
	
	print("Entered where_Is_The_Player_Standing")
	var temp = [player.position.x,player.position.y]
	print (temp)
	for i in snakes.get_children():
		if i.is_in_group("Snake"):
			if player.position.x == i.position.x&&player.position.y==i.position.y:
				rpc("add_player_empty_pos",playerHasMovedName)
				print("collided with "+i.name)
				snakeCollidedWith = i.name
				return "Snake"

	if greenTaskPos.has(temp):
		
		print("Player has been collided with a green task ")
		taskCollidedWith = "greenTask"
		return "easy"
	if yellowTaskPos.has(temp):
		
		print("Player has been collided with a yellow task ")
		taskCollidedWith = "yellowTask"
		return "medium"
	
	if redTaskPos.has(temp):
		print("Player has been collided with a red task ")
		taskCollidedWith = "RedTask"
		return "hard"
	print("Player is on empty tile")
	return check_if_on_empty_tile(playerHasMovedName)
	

sync func add_empty_tile_pos(playerHasMovedName,wayType):
	var playerHasMoved = players.get_node(str(playerHasMovedName))
	var temp = [playerHasMoved.position.x,playerHasMoved.position.y]#old pos
	playersEmptyPos[playerHasMoved.playerCount-1]=0
	if !playersEmptyPos.has(temp):
		match wayType:
			"green":
				greenWayEmptyTilePos.append(temp)
			"yellow":
				yellowWayEmptyTilePos.append(temp)
			"red":
				redWayEmptyTilePos.append(temp)
		print(str(temp)+" has been added to "+wayType+" arrayEmpty")
	
sync func add_player_empty_pos(playerHasMovedName):
	var playerToMove = players.get_node(str(playerHasMovedName))
	var temp = [playerToMove.position.x,playerToMove.position.y]
	playersEmptyPos[playerToMove.playerCount-1] = temp




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
	#print(str(temp))
	if (temp[0]!=firstTile[0]||temp[1]!=firstTile[1])&&(temp[0]!=lastTile[0]||temp[1]!=lastTile[1]):
		
		if temp[1]<=greenArea[0]&&temp[1]>=greenArea[1]:
			print("Player has been is on an empty green way tile")
			return "green"
		elif temp[1]<=yellowArea[0]&&temp[1]>=yellowArea[1]:
			print("Player has been is on an empty yellow way tile")
			return "yellow"
		elif temp[1]<=redArea[0]&&temp[1]>=redArea[1]:
			print("Player has been is on an empty red way tile")
			return "red"

	print("non")
	return null





sync func move_snakes(randGreen,randYellow,randRed):
	print("entered move_snakes")
	var snakePos = []
	var newPos=[]
	var randG = randGreen
	var randY = randYellow
	var randR = randRed
	#print("RandGreen= "+randGreen+" \n RandYellow= "+randYellow+" \n RandRed= "+randRed)
	for snake in snakes.get_children():
		if snake.is_in_group("Snake"):
			snakePos = [snake.position.x,snake.position.y]
			if snake.is_in_group("Green"):
				#print("RandGreen= "+str(randG))
				if greenWayEmptyTilePos.size()>0||randGreen>0:
					snake.position.x = greenWayEmptyTilePos[randG][0]
					snake.position.y = greenWayEmptyTilePos[randG][1]
					var removeTile= greenWayEmptyTilePos.find([snake.position.x,snake.position.y])
					if removeTile!=-1:
						greenWayEmptyTilePos.remove(greenWayEmptyTilePos.find([snake.position.x,snake.position.y]))
					if !playersEmptyPos.has(snakePos):
						greenWayEmptyTilePos.append(snakePos)
			elif snake.is_in_group("Yellow"):
				if yellowWayEmptyTilePos.size()>0||randY>0:
					snake.position.x = yellowWayEmptyTilePos[randY][0]
					snake.position.y = yellowWayEmptyTilePos[randY][1]
					var removeTile= yellowWayEmptyTilePos.find([snake.position.x,snake.position.y])
					if removeTile!=-1:
						yellowWayEmptyTilePos.remove(yellowWayEmptyTilePos.find([snake.position.x,snake.position.y]))
					if !playersEmptyPos.has(snakePos):
						yellowWayEmptyTilePos.append(snakePos)
			elif snake.is_in_group("Red"):
				if redWayEmptyTilePos.size()>0||randR>0:
					snake.position.x = redWayEmptyTilePos[randR][0]
					snake.position.y = redWayEmptyTilePos[randR][1]
					var removeTile= redWayEmptyTilePos.find([snake.position.x,snake.position.y])
					if removeTile!=-1:
						redWayEmptyTilePos.remove(redWayEmptyTilePos.find([snake.position.x,snake.position.y]))
					if !playersEmptyPos.has(snakePos):
						redWayEmptyTilePos.append(snakePos)
	yield(get_tree().create_timer(1.5),"timeout")

sync func Show_SnakeBattlePopUp(playerWillFight,snakeOpponent):
	rpc("hide_Score")
	var playerFight = players.get_node(str(playerWillFight))
	var snakeFight = snakes.get_node(str(snakeOpponent))
	snakeBattlePopUp.get_node("BattleBetween").text = str(snakeFight.get_snakeName())+ " vs "+str(playerFight.username)

	var snakeImage = snakeBattlePopUp.get_node("Snake")
	var playerImage = snakeBattlePopUp.get_node("Player")
	snakeImage.texture = load("res://Assets/Snakes/"+str(snakeOpponent)+"Head.png")
	playerImage.texture = load(playerFight.get_mycharhead())
	if player.name == playerWillFight:
		snakeBattlePopUp.get_node("Fight").show()
		snakeBattlePopUp.get_node("Forfeit").show()
	snakeBattlePopUp.show()

func _on_Fight_pressed():
	rpc("change_to_Snake_Battle",snakeCollidedWith,player.name)

sync func change_to_Snake_Battle(snakeWillFight,playerWillFightName):
	print("Will change to battle scene for "+str(snakeWillFight)+" and "+str(player.name))
	snakeBattlePopUp.get_node("Fight").hide()
	snakeBattlePopUp.get_node("Forfeit").hide()
	snakeBattlePopUp.hide()

	canvas.add_child(load("res://Snakes/SnakesBattle/SnakeBattle.tscn").instance())
	var child = canvas.get_node("SnakeBattle")
	child.position = yourTurn.position
	child.set_fighter(str(playerWillFightName))
	child.set_opponent(str(snakeWillFight))

func _on_Forfeit_pressed():
	snakeBattleResult.get_node("OK").show()
	rpc("show_snake_battle_result",snakeCollidedWith,player.name)
	

sync func show_snake_battle_result(snakeCollidedWithPlayer,playerName):
	snakeBattleResult.show()
	var forfietPlayer = players.get_node(str(playerName))
	var opponent = snakes.get_node(str(snakeCollidedWithPlayer))
	var rand = opponent.get_goBack()
	snakeBattleResult.get_node("Status").text =str( forfietPlayer.username) +" retreated!"
	snakeBattleResult.get_node("Result").text = "Shall take "+str(rand)+" backwards"

sync func player_Go_Backwards(collidedSnake,forfeitPlayer):
	snakeBattleResult.hide()
	var snake = snakes.get_node(collidedSnake)
	var forfiet = players.get_node(forfeitPlayer)
	print("Will go backward according to "+str(collidedSnake)+" and "+str(forfeitPlayer))
	snakeBattlePopUp.get_node("Fight").hide()
	snakeBattlePopUp.get_node("Forfeit").hide()
	snakeBattlePopUp.hide()
	for child in players.get_children():
		if child.is_in_group("Player"):
			child.get_node("follow").set_remote_node("")#remove all the camera from all
	forfiet.get_node("follow").set_remote_node(camera.get_path())
	if forfeitPlayer== player.name:
		backwards = true
		triggerIt=false
		move_player(forfeitPlayer,snake.get_goBack())

	
func player_is_dead():
	snakeBattleResult.get_node("OK").hide()
	rpc("player_Go_Backwards",snakeCollidedWith,player.name)
	if canvas.has_node("snakeBattlePopUp"):
		rpc("delete_node",canvas.name,"SnakeBattle")


func snake_is_dead():
	print("Snake is dead!")
	rpc("delete_node",canvas.name,"SnakeBattle")
	if snakeCollidedWith!="BossSnake":
		loopTurns()
	else:
		rpc("victory",player.name)

sync func delete_node(parentName,childName):
	var parent = get_node(str(parentName))
	parent.get_node(str(childName)).queue_free()

func last_tile(playerOnLastTile):
	snakeCollidedWith="BossSnake"
	lastTilePopup.get_node("Fight").show()
	lastTilePopup.get_node("Solve").show()
	rpc("showLastTilePopup")

sync func showLastTilePopup():
	lastTilePopup.show()

sync func hideLastTilePopup():
	lastTilePopup.get_node("Fight").hide()
	lastTilePopup.get_node("Solve").hide()
	lastTilePopup.hide()
	bossSnakeGoBackwords=true

func _on_FightLastTile_pressed():
	rpc("hideLastTilePopup")
	rpc("change_to_Snake_Battle","BossSnake",player.name)


func _on_SolveLastTile_pressed():
	pass # Replace with function body.

sync func victory(playerWinner):
	Persistent_nodes.get_node("CanvasLayer").get_node(str(playerWinner)).tile=101
	var winner = players.get_node(playerWinner)
	PlayersTurns.modify_player_tile(winner)
	playersRanks.get_node("Congrats").text=str(winner.username)+" Is the winner!"
	PlayersTurns.sort_players_Ranking_desc()
	var playRank
	for rank in rand_range(1,numberOfPlayers):
		rank+=1
		playRank = PlayersTurns.get_player_rank_now()
		players.remove_child(playRank)
		playRank.position = Vector2(0,0)
		playersRanks.get_node(str(rank)).add_child(playRank)
		playersRanks.get_node(str("rank"+str(rank))).show()
		playersRanks.get_node(str("player"+str(rank))).text = playRank.username
		playersRanks.get_node(str("player"+str(rank))).show()
	playersRanks.show()
	playersRanks.get_node("Timer").start()


func _on_Timer_timeout():
	for child in Persistent_nodes.get_node("CanvasLayer").get_children():
					if child.is_in_group("Score"):
						child.queue_free()
	for child in Persistent_nodes.get_children():
		if child.is_in_group("Username"):
			child.queue_free()
	PlayersTurns.erase_everything()
	Network.reset_network_connection()
	get_tree().change_scene("res://UI/Main.tscn")



func _on_TasksLayer_task_finished(taskPassingResult,playerName):
	if taskPassingResult:
		triggerIt=false
		rpc("player_turn",playerName,1)
	else:
		loopTurns()
