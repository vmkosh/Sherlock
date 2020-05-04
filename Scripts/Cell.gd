extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var col = null
var row = null
var tile = preload("res://Classes/Tile.tscn")
var bigCell = preload("res://Classes/BigTile.tscn")
var tiles = Array()

func _init(param_col, param_row, x, y):
	col = param_col
	row = param_row
	position.x = x
	position.y = y
# Called when the node enters the scene tree for the first time.
func _ready():
	var bc = bigCell.instance()
	bc.connect("tileSelected", self, "_on_Tile_selected")
	bc.init(col, row)
	bc.position.x = 32
	bc.position.y = 16
	add_child(bc)
	for i in range(0,6):
		var s = tile.instance()		
		s.position = Vector2((i % 3) * 32 , (i / 3) * 32)
		s.init(load("res://Tiles/%s/icon%d.png" % [row, i]), col, row, i)
		s.savePosition()
		tiles.push_back (s)
		s.scale = Vector2(0.5,0.5)
		add_child(s)
		

func _on_Tile_selected(param_col, param_row, param_num):
	print("qe")
	if param_col == col && param_row == row:
		for tile in tiles:
			tile.hide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
