extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Cell = preload("res://Scripts/Cell.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	for row in Global.ROW:
		var cell = Cell.new(1, row, 16, 0 + (i * 64))
		i += 1
		add_child(cell)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
