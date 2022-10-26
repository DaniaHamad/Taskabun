extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 6
var No_of_players=2
var No_of_current_players=1
var theme ="Park"

var server = null
var client = null

var ip_address = ""
var current_player_username = ""
var allow_join=true

var client_connected_to_server = false



var networked_object_name_index = 0 setget networked_object_name_index_set
puppet var puppet_networked_object_name_index = 0 setget puppet_networked_object_name_index_set

onready var client_connection_timeout_timer = Timer.new()

func _ready() -> void:
	add_child(client_connection_timeout_timer)
	client_connection_timeout_timer.wait_time = 10
	client_connection_timeout_timer.one_shot = true
	
	client_connection_timeout_timer.connect("timeout", self, "_client_connection_timeout")
	
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		#and not ip.ends_with(".1"): means we are getting a physical wifi address not a virtual one
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):#and not ip.ends_with(".1")
			ip_address = ip
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")

func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, No_of_players)
	get_tree().set_network_peer(server)
	Music.stop()
	get_tree().change_scene("res://UI/Loppy.tscn")
	
	
func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	client_connection_timeout_timer.start()
	Music.stop()
	get_tree().change_scene("res://UI/Loppy.tscn")
	
	

	
#when we disconnected from the server
#we are no longger using our network connection
#then our peer of network needs to be destroied >>null
func reset_network_connection() -> void:
	if get_tree().has_network_peer():
		get_tree().set_network_peer(null)

func _connected_to_server() -> void:
	print("Successfully connected to the server")
	client_connected_to_server = true
	

func _server_disconnected() -> void:
	print("Disconnected from the server")

func _client_connection_timeout():
	if client_connected_to_server == false:
		print("Client has been timed out")
		
		reset_network_connection()


func _connection_failed():

	reset_network_connection()
	

func puppet_networked_object_name_index_set(new_value):
	networked_object_name_index = new_value

func networked_object_name_index_set(new_value):
	networked_object_name_index = new_value
	#if we are the active node and we updated the name index we wanna make all clients updates their index too
	if get_tree().is_network_server():
		rset("puppet_networked_object_name_index", networked_object_name_index)
