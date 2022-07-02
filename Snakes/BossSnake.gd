extends "res://Snakes/Snake.gd"
signal animation_Attack_Finished_Snake()
signal snake_Got_Hurt()
signal player_in_reach()

func _ready():
	set_snakeName("Boss Snake")
	set_goBack(15)
	set_snakeHB(100)
	set_snakeBite(30)

func attack_animation_finished():
	emit_signal("animation_Attack_Finished_Snake")


func _on_HurtBox_area_entered(area):
	emit_signal("snake_Got_Hurt")


func _on_PlayerDetector_area_entered(area):
	emit_signal("player_in_reach")
