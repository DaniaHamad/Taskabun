extends Sprite

var task setget , getTaskType
func _ready():
	if texture.resource_path == "res://Assets/Background/TaskEasyGreen.png":
		task = "green"
	elif texture.resource_path =="res://Assets/Background/TaskMediumYellow.png":
		task = "yellow"
	else:
		task = "red"

func getTaskType():
	return task
