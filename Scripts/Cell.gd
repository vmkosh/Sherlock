extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var col = null
var row = null
var tile = preload("res://Classes/Tile.tscn")
var tiles = Array()

func _init(param_col, param_row, x, y):
	col = param_col
	row = param_row
	position.x = x
	position.y = y
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(0,6):
		print(i)
		var s = tile.instance()
		
		s.position = Vector2((i % 3) * 32 , (i / 3) * 32)
		s.init(load("res://Tiles/%s/icon%d.png" % [row, i]), col, row, i)
		add_child(s)
		s.savePosition()
		tiles.push_back (s)
		s.scale = Vector2(0.5,0.5)
		print(s.position)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass