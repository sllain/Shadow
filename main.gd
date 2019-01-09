extends Node2D
class_name Main
var scene = null
var map = null
var cam = null

func _ready():
	OS.window_size *= 3
	OS.window_position = Vector2(20,20)
	
	var cm = $scene/TileMap/player/Camera2D
	var rc = $scene/Container
	cm.limit_left = rc.margin_left
	cm.limit_top = rc.margin_top
	cm.limit_right = rc.margin_right
	cm.limit_bottom = rc.margin_bottom
	
	scene = $scene
	map = $scene/TileMap	
	cam = cm
	sys.player.team = 1
	cm.current = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_main_tree_entered():
	sys.main = self
	sys.player = $scene/TileMap/player
	pass # Replace with function body.
