extends Node2D
#血条组件
var masCha = null
var battle = null
var valSpr = null
var valSpr2 = null
var spVal = null
var anim = null
var offset = Vector2(0,0)
var maxW = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	masCha = sys.player
	valSpr = get_node("val")
	valSpr2 = get_node("val2")
	spVal = get_node("spVal")
	anim = $AnimationPlayer
	offset = position
	maxW = valSpr.region_rect.size.x
	masCha.connect("onHurt",self,"runHurt")
	masCha.connect("onPause",self,"pause")
	
func pause(bl = true):
	if bl :
		set_process(false)
		valSpr2.modulate = Color("ffffff")
	else:
		set_process(true)
		valSpr2.modulate = Color("e40000")

func _process(delta):
	#position = mas.global_position + offset
	if valSpr.region_rect.size.x < valSpr2.region_rect.size.x :
		valSpr2.region_rect.size.x -= 10*delta
	spVal.region_rect.size.x = masCha.sp / 100.0 * maxW
	if masCha.isSpFull():
		if !anim.is_playing() : anim.play("shine")
	elif anim.is_playing() : 
		anim.stop(true)
		spVal.modulate = Color("3d65a8")

func runHurt(atkInfo):
	valSpr.region_rect.size.x = float(masCha.hp)/masCha.maxHp * maxW
	