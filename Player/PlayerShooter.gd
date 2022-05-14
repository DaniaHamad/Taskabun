extends KinematicBody2D

const speed = 400


var hp = 100 setget set_hp
var playerCount =1 setget set_playerCount
var mychar="" setget set_mychar,get_mychar
var velocity = Vector2(0, 0)
var can_shoot = true
var is_reloading = false
var myOval="" setget set_myOval


var username_text = load("res://Player/Username_text.tscn")
var username setget username_set
var username_text_instance = null

puppet var puppet_myOval="" setget puppet_myOval_set
puppet var puppet_hp = 100 setget puppet_hp_set
puppet var puppet_playerCount =1 setget puppet_playerCount_set
puppet var puppet_char = "" setget puppet_char_set
puppet var puppet_position = Vector2(0, 0) setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0
puppet var puppet_username = "" setget puppet_username_set


onready var tween = $Tween
onready var sprite = $Sprite 
onready var reload_timer = $Reload_timer
#onready var shoot_point = $Shoot_point
onready var hit_timer = $Hit_timer

func _ready():
	
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	
	username_text_instance = Global.instance_node_at_location(username_text, Persistent_nodes, global_position)
	
	username_text_instance.player_following = self
	
	
	#at start we are unable to shoot(in the loppy)
	update_shoot_mode(false)
	
	#adding our self to the alive player array at global
	Global.alive_players.append(self)
	
	#wait tell the idle frame,because even if we are ready network might be not raedy
	#so we have to wait for it to use the multiplayer(network) stuff
	yield(get_tree(), "idle_frame")
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = self

func _process(delta: float) -> void:
	if username_text_instance != null:
		#if the username_text node exists we need to name it as a node a unique name for each player
		username_text_instance.name = "username" + name
	
	if get_tree().has_network_peer():
		# and visible ,because if we are not visible means we're dead so we should not be able to shoot
		if is_network_master() and visible:
			var x_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
			var y_input = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
			
			velocity = Vector2(x_input, y_input).normalized()
			
			move_and_slide(velocity * speed)
			
			look_at(get_global_mouse_position())
			
		else:
			rotation = lerp_angle(rotation, puppet_rotation, delta * 8)
			#tween not active measn the player is not moving because we are not receiving a pakeet(lag)
			#we need to predict the player next position pased on the last known speed ,untill we recieve a packet to update position
			if not tween.is_active():
				move_and_slide(puppet_velocity * speed)
				
	#we check for health if  it=0 then our player should die
	if hp <= 0:
		if username_text_instance != null:
			username_text_instance.visible = false
		
		if get_tree().has_network_peer():
			if get_tree().is_network_server():
				rpc("destroy")
				
	
		
func set_myOval(x):
	myOval=x
	if get_tree().has_network_peer():
		if is_network_master():
			$oval.texture=load(myOval)
			rset("puppet_myOval", myOval)

			
func puppet_myOval_set(new_value):
	puppet_myOval = new_value
	if get_tree().has_network_peer():
		if not is_network_master():
			$oval.texture=load(puppet_myOval)
			myOval = puppet_myOval
			
			

func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func set_hp(new_value):
	hp = new_value
	#after changeing our hp value we need to update it on all clients as well
	if get_tree().has_network_peer():
		#this means that we are the active player and we need to tell all the other players
		if is_network_master():
			rset("puppet_hp", hp)

			
func puppet_hp_set(new_value):
	puppet_hp = new_value
	
	if get_tree().has_network_peer():
		if not is_network_master():
			hp = puppet_hp


func set_playerCount(new_value):
	playerCount = new_value
	#after changeing our hp value we need to update it on all clients as well
	if get_tree().has_network_peer():
		#this means that we are the active player and we need to tell all the other players
		if is_network_master():
			rset("puppet_playerCount", playerCount)

			
func puppet_playerCount_set(new_value):
	puppet_playerCount = new_value
	
	if get_tree().has_network_peer():
		if not is_network_master():
			playerCount = puppet_playerCount



			
func set_mychar(new_value):
	mychar = new_value
	if get_tree().has_network_peer():
		if is_network_master():
			$Sprite.texture=load(mychar)
			rset("puppet_char", mychar)
			
func get_mychar():
	return mychar	

func puppet_char_set(new_value):
	puppet_char = new_value
	if get_tree().has_network_peer():
		if not is_network_master():
			$Sprite.texture=load(puppet_char)
			mychar = puppet_char

func username_set(new_value) -> void:
	username = new_value
	if get_tree().has_network_peer():
		if is_network_master() and username_text_instance != null:
			username_text_instance.text = username
			rset("puppet_username", username)
			
		

			
func puppet_username_set(new_value) -> void:
	puppet_username = new_value
	if get_tree().has_network_peer():
		if not is_network_master() and username_text_instance != null:
			username_text_instance.text = puppet_username


func _network_peer_connected(id) -> void:
	rset_id(id, "puppet_username", username)
	rset_id(id, "puppet_char", mychar)
	rset_id(id, "puppet_myOval", myOval)



func _on_Network_tick_rate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			rset_unreliable("puppet_position", global_position)
			rset_unreliable("puppet_velocity", velocity)
			rset_unreliable("puppet_rotation", rotation)
			
			

sync func update_position(pos):
	global_position = pos
	puppet_position = pos

func update_shoot_mode(shoot_mode):
	if not shoot_mode:
		sprite.set_region_rect(Rect2(0, 1500, 256, 250))
	else:
		sprite.set_region_rect(Rect2(512, 1500, 256, 250))
	
	can_shoot = shoot_mode

func _on_Reload_timer_timeout():
	is_reloading = false

func _on_Hit_timer_timeout():
	#this will set our modulate color back to normal
	modulate = Color(1, 1, 1, 1)

#this checks if a bullet has enterd our hit box
func _on_Hitbox_area_entered(area):
	
	if get_tree().is_network_server():
		if area.is_in_group("Player_damager") and area.get_parent().player_owner != int(name):
			#we wanna get the damage amount
			rpc("hit_by_damager", area.get_parent().damage)
			#we wanna tell the bullet to destroy it self
			area.get_parent().rpc("destroy")

#sync means excute on both this player and every other one
sync func hit_by_damager(damage):
	#recue the our health by the damage amount
	hp -= damage
	#making our charcter flash white
	modulate = Color(5, 5, 5, 1)
	#this will wait .1 second and then our modulate color will go back normal
	hit_timer.start()

#this function is for when the game ends,we need to reset the player with new heath 
#also bring back the dead players(hidden) to be alive again(visible)
#reset the network mastre
#re add our self to the alive array
#to start a new round of the game
sync func enable() -> void:
	hp = 100
	can_shoot = false
	update_shoot_mode(false)
	username_text_instance.visible = true
	visible = true
	$CollisionShape2D.disabled = false
	
	
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = self
	
	if not Global.alive_players.has(self):
		Global.alive_players.append(self)

sync func destroy() -> void:
	username_text_instance.visible = false
	visible = false
	#why we chose to just 'hide' the player insted of actually destroy it or queue it free
	#cause the clients will try to  reinstance the player, instead we can just hide it
	$CollisionShape2D.disabled = true
	
	#we need to remove our self from the alive player array when we are dead
	Global.alive_players.erase(self)
	
	if get_tree().has_network_peer():
	#means if our player is destroied ,we wanna destroy its reference in the global script	
		if is_network_master():
			Global.player_master = null

#this function will excute when our current node(player) gets destroied
func _exit_tree() -> void:
	#we need to remove our self from the alive player array when we leave
	Global.alive_players.erase(self)
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = null


