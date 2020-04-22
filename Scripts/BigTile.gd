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
	
func init(sprite, param_col, param_row):
	texture = sprite
	row = param_row
	col = param_col
	
	

# Called when the node enters the scene tree for the first time.
func _ready():	
	pass
	
func _process(delta):	
	if mouse_in && Input.is_action_just_released("left_click"):
		if "num" in Global.dragged:
			var dragged = Global.dragged
			if col == dragged.col && row == dragged.row:
				emit_signal("tileSelected", col, row, dragged.num)


func _on_Area2D_mouse_entered():
	mouse_in = true


func _on_Area2D_mouse_exited():
	mouse_in = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
