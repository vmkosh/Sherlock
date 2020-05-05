extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var row
var col
var num

var mouse_in = false
var dragging = false
var current = null
var initialPosition

signal dropped(row, num)
signal hidden(col, row, num)

func _init():
	pass
func savePosition():
	initialPosition = position

func init(sprite, param_col, param_row, param_num):
	texture = sprite
	row = param_row
	col = param_col
	num = param_num
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	initialPosition = position

func _process(delta):
	if mouse_in && Input.is_action_pressed("right_click"):
		visible = false
		emit_signal("hidden", col, row, num)
	if mouse_in && Input.is_action_pressed("left_click") && GL.dragged == null:
		scale = Vector2(1,1)
		z_index = 1
		dragging = true
		current = get_viewport().get_mouse_position()
		GL.dragged = self
	if dragging && Input.is_action_pressed("left_click"):
		position = initialPosition - current + get_viewport().get_mouse_position()
	elif dragging :
		scale = Vector2(0.5,0.5)
		z_index = 0
		position = initialPosition
		dragging = false
		GL.dragged = null
		EB.publish("tileDropped_%s" % row, {"num": num})
	else:
		dragging = false


func _on_Area2D_mouse_entered():
	mouse_in = true


func _on_Area2D_mouse_exited():
	mouse_in = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
