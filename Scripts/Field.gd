extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var bottomClues = preload("res://Classes/ColumnClues.tscn").instance()
	bottomClues.setup(Logic.clues[GL.CLUETYPE.COLUMN])	
	bottomClues.position.y = 640
	bottomClues.position.x = 64
	add_child(bottomClues)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
