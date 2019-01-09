extends Chara

export var control = true

# Called when the node enters the scene tree for the first time.
func _ready():
	setHp(150)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if control == false : return
	if Input.is_action_pressed("ui_up"):
		inputMove.y = -1
	elif Input.is_action_pressed("ui_down"):
		inputMove.y =  1
	else:
		inputMove.y = 0
	if Input.is_action_pressed("ui_left"):
		inputMove.x =  -1
		if nowAnim == "jump" :
			setDire(inputMove.x)
			moveE(moveSpeed)
	elif Input.is_action_pressed("ui_right"):
		inputMove.x = 1	
		if nowAnim == "jump" :
			setDire(inputMove.x)
			moveE(moveSpeed)
	else:
		inputMove.x = 0
	
	if inputMove.x != 0 :
		act("move",inputMove.x,inputMove.y)
	else:
		act("idle",inputMove.x,inputMove.y)
		
	if Input.is_action_just_pressed("A"):
		act("atk",inputMove.x,inputMove.y)
	elif Input.is_action_just_pressed("ui_select"):
		act("jump",inputMove.x,inputMove.y)

var atk_bl = true
var atkA_bl = true
var atkB_bl = true
var jumpNum = 0

func act(var name,var inX = 0,var inY = 0):
	
	if name == "move" && actLv == 0:
		setDire(inX)
		if nowAnim != "move" :
			play("move")
			moveE(moveSpeed)
		else:
			moveE(moveSpeed)
	elif name == "idle" && nowAnim == "move" && actLv == 0:
		if nowAnim == "idle":
			move()
		else:
			play(name)
	elif name == "idle" && nowAnim == "idle":
		if inY == 1: 
				move(0,-10)
	elif name == "jump" && actLv < 15 && jumpNum < 2:
		setDire(inX)
		play("jump",1)		
		move(abs(inX)*moveSpeed,200)
		jumpNum += 1
		atkBl()
		
	if name == "atk" && actLv <= 12 && inX != 0 :
		move()
		play("atk",14,0.85)
		gravLk = true
	if name == "atk" && actLv <= 15 && inY > 0 && state == 1 && atkA_bl:
		play("atkA",15)
		gravLk = true
		atkA_bl = false
	elif name == "atk" && actLv <= 15 && inY < 0 && atkB_bl:
		play("atkB",15)
		atkB_bl = false
	if name == "atk" && actLv <= 20 && inX != 0 && isSpFull(true):
		move()
		play("aoyi1",21)
		gravLk = true	
	
	if name == "atk" && actLv < 10 && (atk_bl || state == 0):
		move()
		play("atk",11)
		gravLk = true
		atk_bl = false
	elif name == "atk" && actLv == 11 && (nowTime >= 0.10):
		move()
		play("atk",12,0.45)
		gravLk = true
	elif name == "atk" && actLv == 12  && (nowTime >= 0.60):
		move()
		play("atk",13,0.85)
		gravLk = true
	
	
		
func _down():
	._down()
	atkBl()
	jumpNum = 0

func atkBl():
	atk_bl = true
	atkA_bl = true
	atkB_bl = true

var hitChas = []
func _atkIng(atkInfo):
	addSp(atkInfo.rate * 5)
	if nowAnim == "aoyi1" && sys.isClass(atkInfo.hitObj,"Chara"):
		hitChas.append(atkInfo.hitObj)
		
func aoyi1Run():
	var info = AtkInfo.new()
	info.rate = 1
	info.x = 0
	info.y = 100
	info.pa = 0.15
	info.pb = 0.15
	info.atkCha = self
	info.atkObj = self
	for i in range(5):
		for i in hitChas:
			info.hitObj = i
			info.hitCha = i
			if sys.isClass(i,"Chara"):i._hit(info)
		yield(get_tree().create_timer(0.08),"timeout")
	hitChas.clear()

var aiTime = [0,0,0,0]
func _ai(delta):
	if !sys.isClass(aiCha,"Chara"):return
	var lPos:Vector2 = aiCha.position - position
	var l = lPos.length()
	var pos = lPos.normalized()
	var lxy = lPos.abs()
	if l > 300:return
	
	for i in range(aiTime.size()):
		if aiTime[i] > 0 : aiTime[i] -= delta
	
	if lPos.y >= 0:
		act("move",pos.x,0)
	elif lxy.y >= 5:
		act("jump",pos.x,0)
	
	if lxy.x < 20 && lxy.y < 5:
		act("atk")

	if lxy.x < 30 && lxy.y < 5 && aiTime[1] <= 0:
		act("atk",0,-1) 
		aiTime[1] = 3
	elif lxy.x < 20 && lxy.y < 30 && lPos.y < 0 && aiTime[2] <= 0:
		act("atk",0,1)
		aiTime[2] = 3
	elif lxy.x < 80 && lxy.y < 2 && isSpFull():
		act("atk",pos.x,0)