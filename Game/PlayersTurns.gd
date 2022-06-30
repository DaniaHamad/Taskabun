extends Node

var players=[]
var playersTurns=[]
var playersRanking=[]

func sort_players_Turns_desc():
	sort_playersArray_desc()
	var array2DSize = players.size()-1
	playersTurns=[]
	for i in range(array2DSize+1):
		playersTurns.append(players[i][0])

func sort_players_Ranking_desc():
	sort_playersArray_desc()
	var array2DSize = players.size()-1
	playersRanking=[]
	for i in range(array2DSize+1):
		playersRanking.append(players[i][0])

func add_player_to_Array_to_get_sorted(playerArray:Array):
	players.append(playerArray)

func modify_player_tile(player):
	var array2DSize = players.size()
	for i in range(array2DSize):
		if players[i][0].name==player.name:
			players[i][1] =int( Persistent_nodes.get_node("CanvasLayer").get_node(str(player.name)).tile)
			break


func get_player_turn_now():
	var player = playersTurns.pop_front()
	playersTurns.push_back(player)
	return player

func get_player_rank_now():
	var player = playersRanking.pop_front()
	playersRanking.push_back(player)
	return player

func sort_playersArray_desc():
	var columnToSort =1
	var array2DSize = players.size()-1
	if array2DSize!=0:
		for j in range(array2DSize):
			for i in range(array2DSize,0+j,-1):
				if (players[i][columnToSort]) > (players[i-1][columnToSort]): 
					var temporaryStore = players[i-1]
					players[i-1] = players[i]
					players[i] = temporaryStore 


func delete_player(player):
	if playersTurns.has(player):
		var index =0
		for playerAndTileArray in players:
			if playerAndTileArray[0]==player:
				playersTurns.remove(playersTurns.find(player))
				playersRanking.remove(playersTurns.find(player))
				players.remove(players.find(playerAndTileArray))
				break


func erase_everything():
	players=[]
	playersTurns=[]
	playersRanking=[]
