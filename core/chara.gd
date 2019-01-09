extends Obj
class_name Chara

signal onHurt(atkInfo)

var moveSpeed = 100
var maxHp = 300
var hp = maxHp
var sp = 0
var atk = 5

export var team = 2

export var aiOn = false
var aiCha = null

func _init():
	className = "Chara"
func _ready():
	masCha = self
	aiCha = sys.player
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if aiOn:_ai(delta)

func _down():
	if nowAnim == "jump" && nowTime < 1:
		move()
		runPlay("jump",1,1)
	elif nowAnim == "hit" && nowTime <= 0.6 && nowTime >= 0.35 :
		runPlay("hit",100,0.65)
		move()
		defStatus = 2
		sys.cameraShake(0.25,60,1)
	
func _fall():
	if nowAnim == "jump" || nowAnim == "idle" || nowAnim == "move":
		runPlay("jump",1,0.5)

func _animEnd():
	if state == 0 :
		runPlay("idle",0)
	else:
		runPlay("jump",1,0.1)

func _hit(atkInfo:AtkInfo):
	pause(atkInfo.pb,true)
	setDire(-atkInfo.atkObj.dire)
	if defStatus == 0 :
		if atkInfo.y > 0 || state != 0:
			runPlay("hit",100,0.4)
			if atkInfo.y == 0 :
				atkInfo.y = 100
		else:
			runPlay("hit",100,0)
	move(-atkInfo.x,atkInfo.y)
	var node = sys.newEff("huohua",position+Vector2(0,-9))
	node.rotation = randi()%22 + 22
	node.scale *= 1.3
	node.scale *= atkInfo.pa / 0.15
	node.z_index = 50
	var blood = sys.newEff("blood",position+Vector2(0,-9),false,dire)
	blood.z_index = 49
	if atkInfo.pb >= 0.15 :
		sys.cameraShake(0.25,60,1)
		se("hit1")
	else:
		se("hit2")
	var hurt = atkInfo.atkCha.atk * atkInfo.rate
	hp -= hurt
	emit_signal("onHurt",atkInfo)
	if hp/maxHp < sp/100.0:sp = hp/maxHp * 100.0
	if hp <= 0 :
		sys.delEff(position,dire)
		del()
	
func addSp(val):
	sp += val
	if hp/maxHp <= (sp+1)/100.0:sp = hp/maxHp * 100.0
	
func isSpFull(consume = false):
	if hp/maxHp <= sp/100.0 : 
		if consume :sp = 0
		return true
	return false
	
func setHp(val):
	maxHp = val
	hp = val

func _ai(delta):
	pass