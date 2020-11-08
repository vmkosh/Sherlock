extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum ROW {HEAD, ARM, TORSO, LOWER, JOINT, LEG}
enum CLUETYPE {COLUMN, NEAR, BETWEEN, TOLEFT, NOTCOL, NOTNEAR, NOTBETWEEN, SELECTED}
var dragged = null

const RowToGL = {
	"A" : "HEAD",
	"B" : "ARM",
	"C" : "TORSO",
	"D" : "LOWER",
	"E" : "JOINT",
	"F" : "LEG"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
