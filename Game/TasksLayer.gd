extends CanvasLayer
signal task_finished(x)
var number_of_cups=0
var duration=0
var hardness=0 
var cup_list=[]
var cup_list_next=[]
var equation_length=0
var equation
var task_number
var my_position
var active_player=false
var direction
var player_name
func select_task(task_hardness,playerName):
	task_number= range(1,3)[randi()%range(1,3).size()]
	
	player_name=playerName
	var task="res://Tasks/Task"+str(task_number)+"/Task"+str(task_number)+".tscn"
	var t=load(task).instance()
	match task_number:	
		0:
			active_player=true;
			var id=Global.my_id
			rpc("upload_task0",id,task_hardness)
		1:
			active_player=true;
			generate_values_1(task_hardness)
			t.set_values(number_of_cups,duration,hardness,cup_list,cup_list_next,true)
		2:
			active_player=true;
			generate_values_2(task_hardness)	
			t.set_values(duration,hardness,equation_length,true)
	if task_number!=0:
		add_child(t)
		t.connect("task_ended",self,"on_task_ended")
		rpc("set_values",number_of_cups,duration,hardness,cup_list,cup_list_next,equation_length)
		rpc("start_task",task_number)




sync func upload_task0(id,task_hardness):
	get_parent().get_node("Camera2D").current=false
	task_number=0	
	var task="res://Tasks/Task"+str(task_number)+"/Task"+str(task_number)+".tscn"
	var t=load(task).instance()
	my_position=Global.player_master.get_position()
	Global.Player_pos=my_position
	t.set_values(id,active_player,task_hardness)	
	get_parent().get_node("Task0Layer").add_child(t)
	t.connect("task_ended",self,"on_task_ended")
	
	
var rng = RandomNumberGenerator.new()
func generate_values_1(x):
	cup_list=[]
	cup_list_next=[]
	number_of_cups=range(2,5)[randi()%range(2,5).size()]
	if x=="easy":
		duration=range(5,10)[randi()%range(5,10).size()]
		hardness=rng.randf_range(.7,2.5)
	elif x=="medium":
		duration=range(8,15)[randi()%range(8,15).size()]	
		hardness=rng.randf_range(.7,2.5)-.2
	else:
		duration=range(15,20)[randi()%range(15,20).size()]	
		hardness=rng.randf_range(.7,2.5)-.5
	var n=number_of_cups
	for i in range(6):
		var r=range(1,n+1)[randi()%range(1,n+1).size()]	
		var pos=range(1,n+1)[randi()%range(1,n+1).size()]	
		if r==pos and r==1:
			pos+=1
		elif r==pos and r>1:
			pos-=1
		cup_list.append(r)	
		cup_list_next.append(pos)
		
func generate_values_2(x):				
	if x=="easy":
		hardness=0
	elif x=="medium":	
		hardness=1
	else:
		hardness=2
	equation_length=range(2,4+hardness)[randi()%range(2,4+hardness).size()]	
	duration=(equation_length*(equation_length-hardness))
		
	
remote func set_values(n,d,h,s,c,l):
	number_of_cups=n
	duration=d
	hardness=h
	cup_list=s
	cup_list_next=c
	equation_length=l
				

remote func start_task(r):
	task_number=r
	var task="res://Tasks/Task"+str(task_number)+"/Task"+str(task_number)+".tscn"
	var t=load(task).instance()
	match task_number:
		1:
			t.set_values(number_of_cups,duration,hardness,cup_list,cup_list_next,false)
		2:
			t.set_values(duration,hardness,equation_length,false)	
	
	add_child(t)
	

	
signal task0_finished	
func on_task_ended(val):
	if task_number==0:
		get_parent().get_node("Camera2D").make_current()
		Global.player_master.update_position(Global.Player_pos)
		emit_signal("task0_finished")
	if active_player:
		emit_signal("task_finished",val,player_name)
	else:
		emit_signal("task_finished",val,player_name)
	active_player=false	



