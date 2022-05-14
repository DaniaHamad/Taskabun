extends Node2D



var tile=1  setget set_tile
var mychar="" setget set_mychar,get_mychar

var myRank="" setget set_myRank
var colorPlayer=Color("FFFFFF")setget set_colorPlayer


var username setget username_set

puppet var puppet_myRank="" setget puppet_myRank_set
puppet var puppet_tile = 1 setget puppet_tile_set
puppet var puppet_char = "" setget puppet_char_set
puppet var puppet_colorPlayer=Color("FFFFFF") setget puppet_colorPlayer_set
puppet var puppet_username = "" setget puppet_username_set
puppet var puppet_position = Vector2(0, 0) setget puppet_position_set

func _ready():
	
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")

	#wait tell the idle frame,because even if we are ready network might be not raedy
	#so we have to wait for it to use the multiplayer(network) stuff
	yield(get_tree(), "idle_frame")
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = self
	
		
func set_myRank(x):
	myRank=x
	if get_tree().has_network_peer():
		if is_network_master():
			$Rank.text=myRank	
			rset("puppet_myRank", myRank)			

			
func puppet_myRank_set(new_value):
	puppet_myRank = new_value
	if get_tree().has_network_peer():
		if not is_network_master():			
			$Rank.text=puppet_myRank
			myRank = puppet_myRank
			
			

func set_tile(new_value):
	tile = new_value
	#after changeing our hp value we need to update it on all clients as well
	if get_tree().has_network_peer():
		#this means that we are the active player and we need to tell all the other players
		if is_network_master():
			$TileNumber.text = str(tile)
			rset("puppet_tile", str(tile))
			
func puppet_tile_set(new_value):
	puppet_tile = new_value
	
	if get_tree().has_network_peer():
		if not is_network_master():
			$TileNumber.text = str(puppet_tile)
			tile = puppet_tile




func set_mychar(new_value):
	mychar = new_value
	if get_tree().has_network_peer():
		if is_network_master():
			$Head.texture=load(mychar)
			rset("puppet_char", mychar)
			
func get_mychar():
	return mychar	


func puppet_char_set(new_value):
	puppet_char = new_value
	if get_tree().has_network_peer():
		if not is_network_master():
			$Head.texture=load(puppet_char)
			mychar = puppet_char

func username_set(new_value) -> void:
	username = new_value
	if get_tree().has_network_peer():
		if is_network_master():
			$PlayerName.text = username
			rset("puppet_username", username)


func puppet_username_set(new_value) -> void:
	puppet_username = new_value
	if get_tree().has_network_peer():
		if not is_network_master() :
			$PlayerName.text = puppet_username
			username = puppet_username

func set_colorPlayer(new_value):
	colorPlayer = Color(new_value)
	#after changeing our hp value we need to update it on all clients as well
	if get_tree().has_network_peer():
		#this means that we are the active player and we need to tell all the other players
		if is_network_master():
			$PlayerColor.color = colorPlayer
			rset("puppet_colorPlayer", colorPlayer)
			
func puppet_colorPlayer_set(new_value):
	puppet_colorPlayer = Color(new_value)
	
	if get_tree().has_network_peer():
		if not is_network_master():
			$PlayerColor.color = puppet_colorPlayer
			colorPlayer = puppet_colorPlayer
			
func _network_peer_connected(id) -> void:
	rset_id(id, "puppet_username", username)
	rset_id(id, "puppet_char", mychar)
	rset_id(id, "puppet_myRank", myRank)
	rset_id(id, "puppet_colorPlayer", colorPlayer)
	rset_id(id, "puppet_tile", tile)

func _exit_tree() -> void:
	pass


func puppet_position_set(new_value) -> void:
	puppet_position = new_value

func _on_Network_tick_rate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			rset_unreliable("puppet_position", global_position)

sync func update_position(pos):
	global_position = pos
	puppet_position = pos
