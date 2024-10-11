class_name Player
extends Sprite2D

var a = 20.0
var color = Color.DODGER_BLUE
var wallThickness = 2
var v1
var v2
var v3

func _init(aCoords) -> void:
	position = aCoords
	var h = a*sqrt(3)/2
	v1 = round(Vector2(-h/2, a/2))
	v2 = round(Vector2(-h/2, -a/2))
	v3 = round(Vector2(h/2, 0))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			get_parent().add_child(Bullet.new(position + v3.rotated(rotation), wallThickness, (get_viewport().get_mouse_position() - position).normalized()))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mousePosition = get_viewport().get_mouse_position()
	var angle = Vector2(1,0).angle_to(mousePosition - position)
	rotation = angle
	
	
func _draw():
	draw_line(v1,v2,color,wallThickness)
	draw_line(v2,v3,color,wallThickness)
	draw_line(v1,v3,color,wallThickness)
	draw_circle(v3, wallThickness, color.inverted())
