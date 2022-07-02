extends Node2D


onready var c=$Control


func _ready():
	var v=c.get_node("Sprite").texture
	$Label.text=str(v)
	$Sprite.texture=v

