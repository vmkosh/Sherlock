extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var row
var col

var mouse_in = false

signal tileSelected(col, row, num)


func _init():
	pass
	
func init(param_col, param_row):
	col = param_col
	row = param_row
	
# Called when the node enters the scene tree for the first time.
func _ready():	
	pass
	
func _process(delta):	
	EB.subscribe("tileDropped_%s" % row, self, "_handle_event")

func _handle_event(data):
	if mouse_in:
		print("got %s %s" % [row, data["num"]])
		texture = load("res://Tiles/%s/icon%d.png" % [row, data["num"]])
		EB.publish("tileSelected_%s" % row, {"col": col, "num": data["num"]})

func _on_Area2D_mouse_entered():
	mouse_in = true


func _on_Area2D_mouse_exited():
	mouse_in = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
