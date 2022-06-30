extends Node2D


signal task_ended(t)
#var operation=['+','-','x','÷']
var operation=['+','-','x']
var rng = RandomNumberGenerator.new()
var length
var equation=[]
var unsolvable=false
var duration=0
var result
var player
var playerPlayedTask
signal task_ready
func _ready():
	randomize()
	$options.hide()
	$result.hide()
	$ready.hide()
	emit_signal("task_ready")


func set_values(d,h,l,p):
	duration=d	
	hardness=h
	player=p
	length=l
	start_task()
		
	
var hardness=0		
func start_task():
	yield(self,"task_ready")
	if player:
		#$CanvasLayer/ReferenceRect.hide()
		$CanvasLayer/TextureRect.hide()
	if not player:
		$options/option1.disabled=true
		$options/option2.disabled=true
		$options/option3.disabled=true
		
	show_message("Think Fast!")
	yield(get_tree().create_timer(3),"timeout")
	if player:
		set_equation(length)
		rpc("get_equation",equation,$equation.text)
	else:
		yield(self,"equation_ready")			
	solve_equation()
	result=equation[0]
	

signal equation_ready		
remote func get_equation(x,v):
	equation=x
	$equation.text=v
	emit_signal("equation_ready")
	
func _on_ready_pressed():
	$counter.stop_timer()
	show_buttons()	

func show_buttons():
	$ready.hide()
	if player:
		$equation.text="Select the right answer"
	var buttons=["options/option1/Label","options/option2/Label","options/option3/Label"]
	buttons.shuffle()
	if player:
		var tempn=range(1,11)[randi()%range(1,11).size()]
		rpc("show_after_shuffle",buttons,tempn,result)
	
sync func show_after_shuffle(buttons,tempn,r):	
	get_node(buttons[0]).text=str(r)
	get_node(buttons[1]).text=str(r*2+3)
	get_node(buttons[2]).text=str(r*2-tempn)
	$options.show()
	$counter2.start_timer(5)
	$counter2.show()
	

func solve_equation():
	var md=equation.count('x')+equation.count('÷')
	var pm=equation.count('+')+equation.count('-')
	for i in md:
		if unsolvable:
			return 0
		solve_x('x','÷')	
	for i in pm:	
		solve_x('+','-')		

func solve_x(op1,op2):
	var m=equation.find(op1,0)
	var d=equation.find(op2,0)
	var val
	if (d==-1 or d>m) and m>-1:
		if op1=='+':
			val=equation[m-1]+equation[m+1]
		else:
			val=equation[m-1]*equation[m+1]
		equation[m-1]=val
		equation.remove(m)
		equation.remove(m)
	elif (m==-1 or m>d)and d>-1:
		if op2=='-':
			val=equation[d-1]-equation[d+1]
		else:
			if equation[d+1]==0:
				unsolvable=true
			else:	
				val=equation[d-1]/equation[d+1]	
		equation[d-1]=val
		equation.remove(d)
		equation.remove(d)
	

func set_equation(le):
	var eq=""
	var tempn
	var tempo
	var eqSentence=[]
	for i in le:		
		tempn=range(0,21)[randi()%range(0,21).size()]
		eq+=" "+str(tempn)	
		eqSentence.append(tempn)		
		if i<le-1:
			operation.shuffle()
			tempo=operation[0]
			eq+=" "+str(tempo)
			if tempo=='x':
				duration+=2
			eqSentence.append(tempo)				
	$equation.text=eq
	equation= eqSentence		

	
func show_message(val):	
	$equation.hide()
	yield(get_tree().create_timer(.5),"timeout")
	$equation.text=val
	$equation.show()
	yield(get_tree().create_timer(3),"timeout")
	$counter.start_timer(duration)
	if player:
		$ready.show()


func _on_option1_pressed():
	if player:
		$counter2.stop_timer()
		$options.hide()
		if $options/option1/Label.text==str(result):
			end_task(true)
		else:
			end_task(false)


func _on_option2_pressed():
	if player:
		$counter2.stop_timer()
		$options.hide()
		if $options/option2/Label.text==str(result):
			end_task(true)
		else:
			end_task(false)	
		

func _on_option3_pressed():
	if player:
		$counter2.stop_timer()
		$options.hide()
		if $options/option3/Label.text==str(result):
			end_task(true)
		else:	
			end_task(false)	
		

func end_task(val):
	if player:
		rpc("task_ended",val)
	
sync func task_ended(val):
	$counter2.stop_timer()
	$options.hide()
	$music.stop()
	if val:		
		$win.play()
		if player:
			$equation.text="Congrats you won!"
			rpc("set_player_won_name",str(get_parent().get_parent().player.name))
		else:
			$equation.text="Player "+""+" won!"	
	else:
		$lose.play()
		if player:
			$equation.text="Sorry you lost!"
		else:
			$equation.text="Player "+""+" lost!"	
	yield(get_tree().create_timer(3),"timeout")
	emit_signal("task_ended",val)
	queue_free()

sync func set_player_won_name(playerName):
	playerPlayedTask = playerName

func _on_counter2_timeIsDone():
	end_task(false)


func _on_counter_timeIsDone():
	show_buttons()
