extends Node

#a reference to player
var player_master = null
var ui = null

#this because we don't actually know which player is alive and which is destroied
#because the dead players are actually just headen not destroied
#each player will add itself to this array at the begining (at ready func)
var alive_players = []
var servers_name=[]
var pos=400

func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance
