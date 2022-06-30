extends KinematicBody2D

const speed = 400


var playerCount =1 setget set_playerCount
var mychar="" setget set_mychar,get_mychar
var mycharhead="" setget set_mycharhead,get_mycharhead
var myOval="" setget set_myOval
var charNum =1 setget set_charNum, get_charNum

var username setget username_set
var username_text = load("res://Player/Username_text.tscn")

var username_text_instance = null

puppet var puppet_myOval="" setget puppet_myOval_set
puppet var puppet_playerCount =1 setget puppet_playerCount_set
puppet var puppet_char = "" setget puppet_char_set
puppet var puppet_charNum = "" setget puppet_charNum_set
puppet var puppet_charhead = "" setget puppet_charhead_set
puppet var puppet_position = Vector2(0, 0) setget puppet_position_set
puppet var puppet_username = "" setget puppet_username_set


onready var tween = $Tween
onready var sprite = $Sprite 

signal animation_Attack_Finished_Player()
signal player_got_hurt()
func _ready():
	
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	
	username_text_instance = Global.instance_node_at_location(username_text, Persistent_nodes, global_position)
	
	username_text_instance.player_following = self

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
			
			
func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()



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

func set_charNum(new_value):
	charNum = new_value
	if get_tree().has_network_peer():
		if is_network_master():
			rset("puppet_charNum", charNum)
			
func get_charNum():
	return charNum

func puppet_charNum_set(new_value):
	puppet_charNum = new_value
	if get_tree().has_network_peer():
		if not is_network_master():
			charNum = puppet_charNum


func set_mycharhead(new_value):
	mycharhead = new_value
	if get_tree().has_network_peer():
		if is_network_master():
			rset("puppet_charhead", mycharhead)
			
func get_mycharhead():
	return mycharhead	

func puppet_charhead_set(new_value):
	puppet_charhead = new_value
	if get_tree().has_network_peer():
		if not is_network_master():
			mycharhead = puppet_charhead



func username_set(new_value) -> void:
	username = new_value
	if get_tree().has_network_peer():
		if is_network_master() and username_text_instance!=null:
			username_text_instance.text = username
			rset("puppet_username", username)
			
		


func puppet_username_set(new_value) -> void:
	puppet_username = new_value
	if get_tree().has_network_peer():
		if not is_network_master() and username_text_instance!=null:
			username_text_instance.text=puppet_username
			username = puppet_username


func _network_peer_connected(id) -> void:
	rset_id(id, "puppet_username", username)
	rset_id(id, "puppet_char", mychar)
	rset_id(id, "puppet_myOval", myOval)
	rset_id(id, "puppet_playerCount", playerCount)
	rset_id(id,"puppet_charhead",mycharhead)
	rset_id(id,"puppet_charNum",charNum)
	



func _on_Network_tick_rate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			rset_unreliable("puppet_position", global_position)
			

sync func update_position(pos):
	global_position = pos
	puppet_position = pos

func _exit_tree() -> void:
	pass

func attack_animation_finished():
	emit_signal("animation_Attack_Finished_Player")


func _on_HurtBox_area_entered(area):
	emit_signal("player_got_hurt")
