extends Node2D

var fighter
var opponent

var fighterPos
var opponentPos

var fighterParent
var opponentParent

var verdict

var playerHB=60
var playerAttack =10
var snakeHB
var snakeAttack =10 

onready var snakeBattleResult = $SnakeBattleResult
onready var timeLeft = $TimeLeft
onready var timer = $TimeLeft/Timer
onready var buttons =$Buttons 
onready var healthBarSnake = $HealthBarSnake
onready var holderHealthSnake = $HealthBarSnake/HolderHealthSnake
onready var healthBarPlayer =$HealthBarPlayer 
onready var snakeHead =$HealthBarSnake/SnakeHead
onready var snakeHealth = $HealthBarSnake/SnakeHealth
onready var playerHead = $HealthBarPlayer/PlayerHead
onready var holderHealthPlayer = $HealthBarPlayer/HolderHealthPlayer
onready var playerHealth = $HealthBarPlayer/PlayerHealth 


var  playerAcceleration= 500
var  playerMaxSpeed = 80
var playerAnimation


enum{
	MOVE,
	STOP,
	ATTACK
}

var playerState = MOVE
var lastKey="Right"
var playerVelocity=Vector2.ZERO
var knockback_vector

var snakeAcceleration = 300
var snakeMaxSpeed = 50
var snakeFriction = 200
enum{
	IDLE,
	CHASE,
	BITE,
}

var snakeVelocity = Vector2.ZERO
var snakeKnockback = Vector2.ZERO

var snakeState = CHASE
var snakeAnimation


func _ready():
	snakeBattleResult.get_node("OK").hide()
	position = Vector2(192,112)

func _physics_process(delta):
	timeLeft.text = str(int(timer.get_time_left()))
	if timeLeft.text!=str(timer.get_time_left()):
		snakeKnockback = snakeKnockback.move_toward(Vector2.ZERO,snakeFriction*delta) 
		snakeKnockback = opponent.move_and_slide(snakeKnockback)
		match playerState:
			MOVE: 
				move_state(delta)
			ATTACK:
				attack_state()
			STOP:
				pass
			
		
	
		match snakeState:
			IDLE:
				pass
			CHASE:
				accelerate_toward_point(fighter.global_position,delta)
			BITE:
				snake_bite()
			
func set_fighter(playerWillFight):
	fighterParent = get_parent().get_parent().get_node("YSortWorld").get_node("Players")
	fighter = get_parent().get_parent().get_node("YSortWorld").get_node("Players").get_node(str(playerWillFight))
	fighterPos = fighter.position
	fighterParent.remove_child(fighter)
	$PlayerPosition.add_child(fighter)
	fighter.position = Vector2(0,0)
	fighter.get_node("SpriteAnimation").texture = load("res://Assets/Animation/PlayerAnimation/SpriteSheet"+str(fighter.charNum)+".png")
	fighter.get_node("SpriteAnimation").show()
	playerAnimation = fighter.get_node("AnimationPlayer")
	fighter.connect("animation_Attack_Finished_Player",self,"Animation_Finished_Player_Attack")
	fighter.connect("player_got_hurt",self,"player_hurt")
	playerHealth.rect_size.x = playerHB
	holderHealthPlayer.rect_size.x = playerHB+3
	playerHead.texture = load("res://Assets/players/head"+str(fighter.charNum)+".png")
	if get_parent().get_parent().player.username == fighter.username:
		snakeBattleResult.get_node("OK").show()
		if OS.get_name() == "Android":
			buttons.show()

func set_opponent(snakeWillSnake):
	opponentParent = get_parent().get_parent().get_node("YSortWorld").get_node("Snakes")
	opponent = get_parent().get_parent().get_node("YSortWorld").get_node("Snakes").get_node(str(snakeWillSnake))
	opponentPos = opponent.position
	opponent.get_node("SpriteAnimation").show()
	snakeAnimation = opponent.get_node("AnimationPlayer")
	opponent.show()
	opponent.connect("animation_Attack_Finished_Snake",self,"Animation_Finished_Snake_Attack")
	opponent.connect("snake_Got_Hurt",self,"snake_Hurt")
	opponent.connect("player_in_reach",self,"player_reach")
	opponentParent.remove_child(opponent)
	$SnakePosition.add_child(opponent)
	opponent.position = Vector2(0,0)
	snakeHB = opponent.snakeHB
	snakeAttack = opponent.snakeBite
	snakeHealth.rect_size.x = snakeHB
	holderHealthSnake.rect_size.x = snakeHB *1.2
	snakeHealth.rect_position.x = (snakeHB-20)*-1
	holderHealthSnake.rect_position.x =(snakeHealth.rect_position.x)-2
	snakeHead.texture = load("res://Assets/Snakes/"+str(opponent.name)+"Head.png")
	
	if opponent.is_in_group("Green"):
		timer.wait_time = 10
	elif opponent.is_in_group("Yellow"):
		timer.wait_time=15
	elif opponent.is_in_group("Red"):
		timer.wait_time = 20
	else:
		timer.wait_time=30
	timer.start()

func move_state(delta):
	if fighter.name == str(get_tree().get_network_unique_id()):
		var input_vector=Vector2.ZERO
		input_vector.x=Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
		input_vector.y=Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
		input_vector= input_vector.normalized()
		rpc("knockback_sync",input_vector)
		rpc("playerAnimation",input_vector,"Run")
		
		playerVelocity=playerVelocity.move_toward(input_vector*playerMaxSpeed,playerAcceleration*delta)
		if Input.is_action_just_pressed("attack"):
			playerState=ATTACK
		move()

sync func knockback_sync(input_vector):
	knockback_vector = input_vector

sync func playerAnimation(input_vector,state):
	match state:
		"Run":
			if input_vector!=Vector2.ZERO:
				if input_vector.x>0:
					playerAnimation.play("RunRight")
					lastKey ="Right"
				else:
					playerAnimation.play("RunLeft")
					lastKey = "Left"
			else:
				playerAnimation.play("Idle"+str(lastKey))
		"Attack":
			playerAnimation.play("Attack"+str(lastKey))
func move():
	playerVelocity = fighter.move_and_slide(playerVelocity)	

sync func attack_state():
	playerVelocity=Vector2.ZERO
	rpc("playerAnimation",0,"Attack")

func Animation_Finished_Player_Attack():
	playerState=MOVE

func Animation_Finished_Snake_Attack():
	snakeState =CHASE

func player_hurt():
	playerHB-=snakeAttack
	playerHealth.rect_size.x-=snakeAttack
	if playerHB==0&&snakeHB!=0:
		rpc("player_lose")

func snake_Hurt():
	snakeKnockback = knockback_vector*150
	snakeHealth.rect_size.x-=playerAttack
	snakeHealth.rect_position.x+=playerAttack
	snakeHB-=playerAttack
	if snakeHB==0&&playerHB!=0:
		rpc("player_won")

func player_reach():
	snakeState = BITE

func snake_bite():
	snakeAnimation.play("Bite")


func accelerate_toward_point(point,delta):
		var direction = opponent.global_position.direction_to(point)
		snakeVelocity = snakeVelocity.move_toward(direction*snakeMaxSpeed,snakeAcceleration*delta)
		opponent.get_node("SpriteAnimation").flip_h = snakeVelocity.x>0
		snakeAnimation.play("Chase")
		opponent.move_and_slide(snakeVelocity)

sync func player_lose():
	var rand = opponent.get_goBack()
	snakeBattleResult.get_node("Status").text = "Defeat!"
	snakeBattleResult.get_node("Result").text = "You Shall take "+str(rand)+" backwards"
	if snakeBattleResult.get_node("OK").is_connected("pressed",get_parent().get_parent(),"snake_is_dead"):
		snakeBattleResult.get_node("OK").disconnect("pressed",get_parent().get_parent(),"snake_is_dead")
	snakeBattleResult.get_node("OK").connect("pressed",get_parent().get_parent(),"player_is_dead")
	
	timer.stop()
	go_back_to_parent()




sync func player_won():
	snakeBattleResult.get_node("Status").text = "Victory!"
	snakeBattleResult.get_node("Result").text = "You Shall stay on your place"
	if snakeBattleResult.get_node("OK").is_connected("pressed",get_parent().get_parent(),"player_is_dead"):
		snakeBattleResult.get_node("OK").disconnect("pressed",get_parent().get_parent(),"player_is_dead")
	snakeBattleResult.get_node("OK").connect("pressed",get_parent().get_parent(),"snake_is_dead")
	timer.stop()
	go_back_to_parent()

func go_back_to_parent():
	fighter.get_node("SpriteAnimation").hide()
	fighter.get_parent().call_deferred("remove_child",fighter)
	fighterParent.call_deferred("add_child",fighter)
	fighter.position = fighterPos
	

	opponent.get_node("SpriteAnimation").hide()
	opponent.get_parent().call_deferred("remove_child",opponent)
	opponentParent.call_deferred("add_child",opponent)
	opponent.position = opponentPos
	if opponent.name =="BossSnake":
		opponent.hide()
	if fighter.name == get_parent().get_parent().player.name:
		rpc("show_snakeBattleResult")


sync func show_snakeBattleResult():
	healthBarPlayer.hide()
	healthBarSnake.hide()
	buttons.hide()
	snakeBattleResult.show()


func _on_Timer_timeout():
	if get_tree().is_network_server():
		rpc("time_is_out")

sync func time_is_out():
	playerState = STOP
	snakeState= IDLE
	var rand = opponent.get_goBack()
	snakeBattleResult.get_node("Status").text = "The time has ran out!"
	snakeBattleResult.get_node("Result").text = "You Shall take "+str(rand)+" backwards"
	if snakeBattleResult.get_node("OK").is_connected("pressed",get_parent().get_parent(),"snake_is_dead"):
		snakeBattleResult.get_node("OK").disconnect("pressed",get_parent().get_parent(),"snake_is_dead")
	snakeBattleResult.get_node("OK").connect("pressed",get_parent().get_parent(),"player_is_dead")
	go_back_to_parent()
