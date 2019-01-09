extends Chara

# Called when the node enters the scene tree for the first time.
func _ready():
	setHp(50)
	aiOn = true
# Called every frame. 'delta' is the elapsed time since the previous frame.

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
	elif name == "jump" && actLv < 10 :
		setDire(inX)
		play("jump",11)		
		move(abs(inX)*moveSpeed,100)

	if name == "atkA" && actLv <= 15 :
		play("atkA",15)
		gravLk = true
	elif name == "atkB" && actLv <= 15:
		play("atkB",15)
	
	if name == "atk" && actLv < 10 :
		move()
		play("atk",11)
		gravLk = true
		
		
func _down():
	._down()


var aiTime = [0,0,0,0]
var moveSt = 0
func _ai(delta):
	if !sys.isClass(aiCha,"Chara"):return
	var lPos:Vector2 = aiCha.position - position
	var l = lPos.length()
	if l > 150:return
	var pos = lPos.normalized()
	var lxy = lPos.abs()
	
	for i in range(aiTime.size()):
		if aiTime[i] > 0 : aiTime[i] -= delta
	if aiTime[0] <= 0 :
		var rn = sys.rndRan(1,100)
		if rn < 40:
			moveSt = 0
			aiTime[0] = 0.5
		elif rn < 70:
			moveSt = 1
			aiTime[0] = 0.2
		else:
			moveSt = 2
			aiTime[0] = 0.3
	else:
		if moveSt == 0 :
			act("move",pos.x,0)
		elif moveSt == 1:
			act("move",-pos.x,0)
		else:
			act("idle",pos.x,0)
#	elif lxy.y >= 5:
#		act("jump",pos.x,0)
	
	if lxy.x < 20 && lxy.y < 5:
		act("atk")

	if lxy.x < 20 && lxy.y < 5 && aiTime[1] <= 0:
		act("atkA",0,0)
		aiTime[1] = 2
	elif lxy.x < 30 && lxy.y < 5  && aiTime[2] <= 0:
		act("atkB",0,0)
		aiTime[2] = 3
		
		