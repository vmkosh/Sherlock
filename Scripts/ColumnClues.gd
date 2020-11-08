extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var clues = [];
var ColumnClue = preload("res://Classes/ColumnClue.tscn")

func setup(param_clues):
	for clue in param_clues:
		clues.append(clue)
	var x = 0
	for clue in clues:
		var cc = ColumnClue.instance()
		cc.setup(clue, x, 0)
		x = x + 66
		add_child(cc)
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
