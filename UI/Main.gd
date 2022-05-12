extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var background = TextureRect.new()
	background.texture = load("res://Assets/background.png")
	background.name = "background"
	background.rect_size=(Vector2(384,216))
	background.expand = true
	var textureRect = TextureRect.new()
	textureRect.texture = load("res://Assets/glowing square.png")
	textureRect.name = "TextureRect"
	textureRect.expand = true
	textureRect.rect_min_size = Vector2(384,216)
	textureRect.rect_size=Vector2(412,282)
			
	textureRect.rect_position=Vector2(-14,-31)
	textureRect.set_stretch_mode(5)
	Persistent_nodes.add_child(background)
	Persistent_nodes.add_child(textureRect)


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
