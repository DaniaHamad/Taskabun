extends Node2D

export var duration=5
var win=false
var number
var round_number=1
onready var c1=$cupsSet/Cup1
onready var c2=$cupsSet/Cup2
onready var c3=$cupsSet/Cup3
onready var c4=$cupsSet/Cup4
signal show_finished
signal label_ready
var hardness=0
signal task_ready
var start_cup_list
var start_cup
var cup_list_next
var player
func _ready():
	if player:
		$CanvasLayer/ReferenceRect.hide()
		$CanvasLayer/TextureRect.hide()
	for x in $cupsSet.get_children():
		x.enable_click(false)
	randomize()
	emit_signal("task_ready")


func set_values(n,d,h,s,c,p):
	number=n
	duration=d	
	hardness=h
	start_cup_list=s
	start_cup=0
	cup_list_next=c
	player=p
	start_task()
	
	
func start_task():
	yield(self,"task_ready")
	$clock.hide()
	delete_extras(number)
	var r=start_cup_list[1]
	show_start(r)
	get_node("cupsSet/Cup"+str(r)).coin=true
	yield(self,"show_finished")
	shuffle(number)
	

func show_message(val,stay):
	$startLabel.hide()
	if player:
		$startLabel.text=val
	else:
		$startLabel.text=""	
	yield(get_tree().create_timer(.5),"timeout")
	$startLabel.show()
	yield(get_tree().create_timer(stay),"timeout")
	$startLabel.hide()
	emit_signal("label_ready")

func show_static_message(val):
	$startLabel.hide()
	$startLabel.text=val
	yield(get_tree().create_timer(.5),"timeout")	
	$startLabel.show()
	$music.stop()
	emit_signal("label_ready")

func show_start(r):
	self.show_message("Look!",1)
	yield(self,"label_ready")
	yield(get_tree().create_timer(1.0),"timeout")
	get_node("cupsSet/Cup"+str(r)).show_coin()
	yield(get_tree().create_timer(1.0),"timeout")
	self.show_message("Shuffle",1)
	yield(self,"label_ready")
	emit_signal("show_finished")
		
var rng = RandomNumberGenerator.new()	
func shuffle(number):
	$Timer.start(duration)
	$secondTimer.start()
	$clock.text=str(duration)
	$clock.show()
	while $Timer.time_left > 0:
		$swipe.play()
		exchange_positions(number)
		yield(get_tree().create_timer(hardness),"timeout")
	

func exchange_positions(number):
	var r=start_cup_list[start_cup]
	var pos=cup_list_next[start_cup]
	start_cup=(start_cup+1)%6
	var p1=get_node("cupsSet/Cup"+str(pos)).position
	var p2=get_node("cupsSet/Cup"+str(r)).position
	var v1=p1
	var v2=p2
	var dis=25
	var dis2=25
	var vis=25
	var vis2=25
	while p1.x!=p2.x or p1.y!=p2.y or v2.x!=v1.x or v2.y !=v1.y:
		
		if abs(v1.x-v2.x)<25:
			vis=abs(v1.x-v2.x)
			#-------
		if v2.x<v1.x:
			v2.x+=vis
			get_node("cupsSet/Cup"+str(r)).position.x=v2.x
		elif v2.x>v1.x:
			v2.x-=dis
			get_node("cupsSet/Cup"+str(r)).position.x=v2.x
			#-----	
		if abs(p1.x-p2.x)<25:
			dis=abs(p1.x-p2.x)
		if p1.x<p2.x:
			p1.x+=dis
			get_node("cupsSet/Cup"+str(pos)).position.x=p1.x
		elif p1.x>p2.x:
			p1.x-=dis
			get_node("cupsSet/Cup"+str(pos)).position.x=p1.x
		#--------
		if abs(v1.y-v2.y)<25:
			vis2=abs(v1.y-v2.y)	
		if v1.y>v2.y:
			v2.y+=vis2
			get_node("cupsSet/Cup"+str(r)).position.y=v2.y
		elif v1.y<v2.y:
			v2.y-=vis2
			get_node("cupsSet/Cup"+str(r)).position.y=v2.y
		#--------		
		if abs(p1.y-p2.y)<25:
			dis2=abs(p1.y-p2.y)	
		if p1.y<p2.y:
			p1.y+=dis2
			get_node("cupsSet/Cup"+str(pos)).position.y=p1.y
		elif p1.y>p2.y:
			p1.y-=dis2
			get_node("cupsSet/Cup"+str(pos)).position.y=p1.y
		yield(get_tree().create_timer(.08),"timeout")	


func get_next_cup(number,r):
	var pos= range(1,number+1)[randi()%range(1,number+1).size()]
	if r==pos and r==1:
		pos+=1
	elif r==pos and r>1:
		pos-=1
	return pos
	
	
		

func _on_Timer_timeout():
	self.show_message("Select",.5)
	yield(self,"label_ready")
	round_number=2
	$startLabel.hide()
	$clock.text=str(5)
	$clock.show()
	$secondTimer.start()
	$ColorRect.hide()
	if player:
		for x in $cupsSet.get_children():
			x.enable_click(true)
	
func _on_secondTimer_timeout():
	var v=int($clock.text)	
	if v>0:
		v-=1
	else:
		$secondTimer.stop()	
	$clock.text=str(v)
	if v==0:
		$secondTimer.stop()	
		$clock.hide()
		if round_number==2:
			$ColorRect.color="#dda91e"
			$ColorRect.show()
			for x in $cupsSet.get_children():
				x.enable_click(false)
			$lose.play()
			rpc("stop_timer",false)
			#self.stop_timer(false)
			#self.show_static_message("Sorry you lost!")
			
signal task_ended(c)

#var Coin=preload("res://Tasks/Task1/coin.tscn")	
signal cup_selected(x)	
sync func stop_timer(val):
	$secondTimer.stop()
	$clock.hide()	
	$ColorRect.color="#dda91e"
	$ColorRect.show()
	for x in $cupsSet.get_children():
		x.enable_click(false)
	$music.stop()
	if val:
		#var coin=Coin.instance()
		$win.play()
		if player:
			self.show_static_message("Congrats you won!")
		else:
			self.show_static_message("Player "+""+" won!")	
		#$coinPosition.add_child(Coin.instance())	
		yield(get_tree().create_timer(2.5),"timeout")
		emit_signal("task_ended",true)
	else:
		$lose.play()
		if player:
			self.show_static_message("Sorry you lost!")	
		else:
			self.show_static_message("Player "+""+" lost!")	
		yield(get_tree().create_timer(2.5),"timeout")
		emit_signal("task_ended",false)
	queue_free()	
		
	

		

func delete_extras(val):
	if val<4:
		c4.queue_free()
		
	if val<3:
		c3.queue_free()	
	
	


