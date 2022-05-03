extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TouchScreenButton_pressed():
	get_tree().change_scene("res://Settings/Settings.tscn")


func _on_JoinGame_pressed():
	Global.instance_node(load("res://UI/JoinServer.tscn"), self)
	#get_tree().change_scene("res://UI/JoinServer.tscn")

onready var create_screen=preload("res://UI/CreateServer.tscn")

func _on_CreateGame_pressed():
	get_tree().change_scene("res://UI/CreateServer.tscn")
