extends Node2D
class_name Eff

var posMove = Vector2()
var spr = null
var anim = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_physics_process(false)
	spr = $spr
	anim = $AnimationPlayer
	anim.connect("animation_finished",self,"animation_finished")

func _physics_process(delta):
	position += posMove * delta

func move(x=0,y=0):
	posMove.x = x
	posMove.y = y
	set_physics_process(true)

func speed(s):
	posMove = posMove.normalized() * s
	
func pause(bl = true):
	if bl :
		anim.playback_speed = 0
		set_physics_process(false)
	else:
		anim.playback_speed = 1
		set_physics_process(true)

func animation_finished(anim_name):
	anim_name = ""
	queue_free()
