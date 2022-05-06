extends Node2D

var fighter
var opponent

var fighterPos
var opponentPos

var fighterParent
var opponentParent


var playerHB=100
var SnakeHB=100

onready var snakeBattleResult = $SnakeBattleResult
onready var timeLeft = $TimeLeft
onready var timer = $TimeLeft/Timer


func _ready():
	$PlayerPress.hide()
	$SnakePress.hide()
	snakeBattleResult.get_node("OK").hide()
	position = Vector2(192,112)

func _process(delta):
	timeLeft.text = str(int(timer.get_time_left()))

func set_fighter(playerWillFight):
	print("enter set_fighter")
	fighterParent = get_parent().get_parent().get_node("YSortWorld").get_node("Players")
	print("The father of "+playerWillFight+" is "+fighterParent.name)
	fighter = get_parent().get_parent().get_node("YSortWorld").get_node("Players").get_node(str(playerWillFight))
	print("fighter is "+ fighter.name)
	fighterPos = fighter.position
	print("fighter pos is "+ str(fighter.position))
	fighterParent.remove_child(fighter)
	$PlayerPosition.add_child(fighter)
	fighter.position = Vector2(0,0)
	if get_parent().get_parent().player.username == fighter.username:
		$PlayerPress.show()
		$SnakePress.show()
		snakeBattleResult.get_node("OK").show()
		

func set_opponent(snakeWillSnake):
	opponentParent = get_parent().get_parent().get_node("YSortWorld").get_node("Snakes")
	opponent = get_parent().get_parent().get_node("YSortWorld").get_node("Snakes").get_node(str(snakeWillSnake))
	opponentPos = opponent.position
	opponentParent.remove_child(opponent)
	$SnakePosition.add_child(opponent)
	opponent.position = Vector2(0,0)
	timer.start()

func _on_PlayerPress_pressed():
	playerHB-=10
	if playerHB==0:
		rpc("player_lose")

sync func player_lose():
	var rand = opponent.get_goBack()
	snakeBattleResult.get_node("Status").text = "Defeat!"
	snakeBattleResult.get_node("Result").text = "You Shall take "+str(rand)+" backwards"
	snakeBattleResult.get_node("OK").connect("pressed",get_parent().get_parent(),"player_is_dead")
	timer.stop()
	go_back_to_parent()


func _on_SnakePress_pressed():
	SnakeHB-=10
	if SnakeHB==0:
		rpc("player_won")


sync func player_won():
	snakeBattleResult.get_node("Status").text = "Victory!"
	snakeBattleResult.get_node("Result").text = "You Shall stay on your place"
	snakeBattleResult.get_node("OK").connect("pressed",get_parent().get_parent(),"snake_is_dead")
	timer.stop()
	go_back_to_parent()

func go_back_to_parent():
	fighter.get_parent().remove_child(fighter)
	fighterParent.add_child(fighter)
	fighter.position = fighterPos
	
	opponent.get_parent().remove_child(opponent)
	opponentParent.add_child(opponent)
	opponent.position = opponentPos
	if fighter.name == get_parent().get_parent().player.name:
		rpc("show_snakeBattleResult")


sync func show_snakeBattleResult():
	snakeBattleResult.show()


func _on_Timer_timeout():
	if get_tree().is_network_server():
		rpc("time_is_out")

sync func time_is_out():
	var rand = opponent.get_goBack()
	snakeBattleResult.get_node("Status").text = "The time has ran out!"
	snakeBattleResult.get_node("Result").text = "You Shall take "+str(rand)+" backwards"
	snakeBattleResult.get_node("OK").connect("pressed",get_parent().get_parent(),"player_is_dead")
	go_back_to_parent()
