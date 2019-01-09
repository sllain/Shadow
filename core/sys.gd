extends Node

var main:Main = null
var publicRes = []
var objPool = []
var player = null

func _ready():
	publicRes.append(preload("res://ex/eff/huohua.tscn"))
	publicRes.append(preload("res://ex/eff/blood.tscn"))
	publicRes.append(preload("res://ex/eff/bo1.tscn"))
	publicRes.append(preload("res://ex/eff/dang1.tscn"))
	publicRes.append(preload("res://ex/eff/dk.tscn"))
	publicRes.append(preload("res://ex/eff/huiChen2.tscn"))
	
	
#百分比随机
func rndPer(var val):
	if randi()%100 < val :
		return true
	return false
#范围随机	
func rndRan(mmin,mmax):
	return randi()%(mmax - mmin + 1) + mmin
#随机	
func rnd(val):
	return randi()%val
#从列表中随机一个元素
func rndListItem(list):
	if list.size() > 0:
		return list[rnd(list.size())]
	return null

func newEff(name,pos,isUi = false,dire = -1): 
	var map = main.map
	var node = load("res://ex/eff/%s.tscn" % name).instance()
	if isUi:
		map.get_node("../uiLayer").add_child(node)
	else:
		map.add_child(node)

	if sys.isClass(node,"Obj"): node.dire = dire
	else:node.scale.x = dire
	node.position = pos
	return node

func delObj(obj):
	objPool.append(obj)
	
func getObj(fileName):
	for i in range(objPool.size()):
		if objPool[i].filename == fileName :
			var obj = objPool[i]
			objPool.remove(i)
			return obj
	return null
		
func cameraShake(uration, frequency, amplitude):
	if notNull(sys.main.cam) :
		sys.main.cam.shake(uration, frequency, amplitude)
	
func notNull(obj):
	if obj == null: return false
	elif !weakref(obj).get_ref() :return false
	return true 
	
func isClass(obj,className):
	if notNull(obj) == false:return false
	var s = obj.get("className")
	if s == null:return false
	elif s == className :return true
	return false
	
func delEff(pos,dire):
	yield(get_tree().create_timer(0.1),"timeout")
	if notNull(player) :player.se("hit2")
	sys.cameraShake(0.25,60,2)
	for i in range(5):
		newEff("dk",pos+Vector2(0,-10),false,-dire)