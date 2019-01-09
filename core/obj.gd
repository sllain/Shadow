extends KinematicBody2D
class_name Obj
var className = "Obj"

signal onDown()
signal onFall()
signal onAnimEnd(name)
signal onHit(atkInfo)
signal onPause(bl) 

var grav = 600
var gravLk = false
var mPos = Vector2()
var inputMove = Vector2()
var actLv = 0
var dire = 1
var stopTime = 0
var masCha = null

var spr = null
var sprSpr = null
var anim = null
var atkBox = null
var effPos = null
var sePlay = null
var pauseTimer = null

var nowAnim = ""
var nowTime = 0.0
var state = 0
var ifDownInfo:IfInfo = IfInfo.new()
var ifFallInfo:IfInfo = IfInfo.new()
var atkInfo = AtkInfo.new()
var defStatus = 0  #0:普通，1：无敌，2：霸体，3：防御
var atkIng = false

class IfInfo:
	extends Reference
	var anim = ""
	var time = 0
	var lv = 0

func _ready():
	anim = $AnimationPlayer
	effPos = $Position2D
	anim.connect("animation_finished",self,"animEnd")
	atkBox = $Area2D
	atkBox.connect("body_entered",self,"_on_Area2D_body_entered")
	spr = $spr
	sprSpr = $spr/Sprite
	sePlay = $AudioStreamPlayer2D
	pauseTimer = $ex/pauseTimer
	pauseTimer.connect("timeout",self,"pauseTimerRun")
	init()

var oldState = 0
var ghostTime = 0
var ghostOn = true
var airTime = 0
var downBl = false
var fallBl = true
func _physics_process(delta):
	if gravLk == false :
		mPos.y += grav * delta
		if mPos.y > 0 && fallBl && state == 1 :
			fallBl = false
			emit_signal("onFall")
			_fall()
			
	mPos = move_and_slide(mPos, Vector2(0,-1))
	if is_on_floor() :
		state = 0
		airTime = 0
		if true:
			if ifDownInfo.anim != "" :
				play(ifDownInfo.anim,ifDownInfo.lv,ifDownInfo.time)
				ifDownInfo.anim = ""
			emit_signal("onDown")
			_down()
			downBl = false
	elif is_on_wall():
		state = 2
	elif is_on_ceiling():
		state = 3
	else:
		airTime += delta
		if airTime > 0.1:state = 1
		
		
	oldState = state
	if stopTime > 0 :
		stopTime -= delta
		if stopTime <= 0:
			anim.playback_speed = 1
	else:
		nowTime += delta
	if playName != "" :
		runPlay(playName,playLv,playTime)
	if ghostOn:
		if ghostTime <= 0	:
			var ghost = preload("res://core/ghost.tscn").instance()
			ghost.init(sprSpr.global_position,sprSpr.texture,dire)
			sys.main.map.add_child(ghost)
			ghostTime = 0.015
		else:ghostTime -= delta
	
	_up()
	
	
func move(x = 0,y = 0):
	mPos.x = x * dire
	mPos.y = -y

func moveE(x = null,y = null):
	if x != null:mPos.x = x * dire
	if y != null:mPos.y = y
	
func atk(rate,x,y,pa,pb):
	atkBox.monitoring = true
	atkInfo.rate = rate
	atkInfo.x = x
	atkInfo.y = y
	atkInfo.pa = pa
	atkInfo.pb = pb
	atkInfo.atkCha = self
	pass

func offAtk():
	atkBox.monitoring = false
	
func setDefSt(val):
	defStatus = val
	
func setActLv(lv):
	actLv = lv

	
func moveIn(var moveVector):
	mPos = moveVector * inputMove
	
func setDire(diref = 1):
	if diref == 0:return
	if diref > 0: dire = 1
	else: dire = -1
	spr.scale.x = dire
	atkBox.scale.x = dire

func gravLk(on):
	gravLk = on

func peneLk(on):
	if on :
		collision_layer = 0
		collision_mask = 1
	else:
		collision_layer = 2
		collision_mask = 3

func ghostLk(on):
	ghostOn = on
	
func se(name,pitch = 1):
	sePlay.pitch_scale = pitch
	sePlay.stream = load("res://res/se/%s.wav" % name)
	sePlay.play()

func shake(uration, frequency, amplitude):
	sys.main.cam.shake(uration, frequency, amplitude)
	
var playName = ""
var playLv = 0
var playTime = 0
func play(name,lv = 0,time = 0):
	playName = name
	playLv = lv
	playTime = time
	actLv = lv

func runPlay(name,lv = 0,time = 0):
	if nowAnim != name :
		fallBl = true
		ifDownInfo.anim = ""
		atkIng = false
		gravLk = false
		defStatus = 0
		peneLk(false)
		ghostOn = false
	anim.play(name)
	nowAnim = name
	actLv = lv
	stopTime = 0
	anim.seek(time)
	nowTime = time
	offAtk()
	playName = ""
	playLv = 0
	playTime = 0
	if lv >= 100 :z_index = 0
	else:z_index = lv
	_play()
	
func end():
	animEnd(nowAnim)
	
func stop(time = 1000.0):
	stopTime = time
	anim.playback_speed = 0
	
func ifDown(anim,lv,time):
	ifDownInfo.anim = anim
	ifDownInfo.lv = lv
	ifDownInfo.time = time
	
func animEnd(name):
	emit_signal("onAnimEnd",name)
	_animEnd()
	
func newEff(name,isUi = false):
	var	pos = Vector2(position.x + effPos.position.x * dire,position.y + effPos.position.y)
	var node = sys.newEff(name,pos,isUi,dire)
	if node as Obj :
		node.masCha = self
		node.dire = dire
	node.z_index = 200
	return node
	
	
func getAnimTime():
	return anim.get_current_animation_pos()
	
func _on_Area2D_body_entered(body):
	if sys.notNull(masCha) &&  body != self &&  sys.isClass(body,"Chara") && body != masCha && masCha.team != body.masCha.team:
		atkInfo.atkCha = masCha
		atkInfo.atkObj = self
		atkInfo.hitCha = body.masCha
		atkInfo.hitObj = body
		masCha._atkIng(atkInfo)
		body._hit(atkInfo)
		body.emit_signal("onHit",atkInfo)
		self.pause(atkInfo.pa)
		atkIng = true
		
func pause(time,shine = false):
	if time == 0 :return
	set_physics_process(false)
	anim.playback_speed = 0
	if shine:
		$spr/Sprite.use_parent_material = false
	self.shine = shine
	pauseTimer.start(time)
	emit_signal("onPause",true)
	
var shine = true
func pauseTimerRun():
	set_physics_process(true)
	anim.playback_speed = 1
	if shine:
		$spr/Sprite.use_parent_material = true
	emit_signal("onPause",false)
	
func del():
	queue_free()
	
func init():
	set_physics_process(true)
	set_process(true)
	show()
	offAtk()
	play("idle",actLv)

func _down():
	pass

func _fall():
	pass
	
func _animEnd():
	pass
	
func _up():
	pass
	
func _hit(atkInfo):
	pass

func _atkIng(atkInfo):
	pass
func _play():
	pass
