extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var c=$Control


func _ready():
	var v=c.get_node("Sprite").texture
	$Label.text=str(v)
	$Sprite.texture=v

