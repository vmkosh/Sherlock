extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var clue;

func setup(param_clue, x, y):
	clue = param_clue
	position.x = x
	position.y = y
	

func _ready():
	var upRow = GL.RowToGL[clue.tile1.left(1)]
	var upCol = int(clue.tile1.right(1)) - 1 
	var upSprite = get_node("TopSprite")
	var downRow = GL.RowToGL[clue.tile2.left(1)]
	var downCol = int(clue.tile2.right(1)) - 1
	var downSprite = get_node("DownSprite")
	print(upRow)
	print(upCol)
	print(downRow)
	print(downCol)
	if upRow > downRow :
		upSprite.texture = load("res://Tiles/%s/icon%d.png" % [upRow, upCol])
		downSprite.texture = load("res://Tiles/%s/icon%d.png" % [downRow, downCol])
	else: 
		downSprite.texture = load("res://Tiles/%s/icon%d.png" % [upRow, upCol])
		upSprite.texture = load("res://Tiles/%s/icon%d.png" % [downRow, downCol])
	#downSprite.position.y = 32
	#add_child(downSprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
