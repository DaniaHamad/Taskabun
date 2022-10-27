extends Control



func _ready():
	if !Music.playing:
		Music.play()
	if !Persistent_nodes.has_node("background"):
		var background = TextureRect.new()
		background.texture = load("res://Assets/background.png")
		background.name = "background"
		background.rect_size=(Vector2(384,216))
		background.expand = true
		var textureRect = TextureRect.new()
		textureRect.texture = load("res://Assets/Animation/RectAnimation/0.png")
		textureRect.name = "TextureRect"
		textureRect.rect_size=Vector2(294,198)
		textureRect.expand = true
		textureRect.rect_position=Vector2(42,10)
		Persistent_nodes.add_child(background)
		Persistent_nodes.add_child(textureRect)




func _on_TouchScreenButton_pressed():
	Music.play_BtnFX()
	get_tree().change_scene("res://Settings/Settings.tscn")


func _on_JoinGame_pressed():
	Music.play_BtnFX()
	Global.instance_node(load("res://UI/JoinServer.tscn"), self)

onready var create_screen=preload("res://UI/CreateServer.tscn")

func _on_CreateGame_pressed():
	Music.play_BtnFX()
	get_tree().change_scene("res://UI/CreateServer.tscn")
