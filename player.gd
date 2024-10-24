class_name Player
extends Sprite2D

var a = 20.0
var color = Color.DODGER_BLUE
var wallThickness = 2
var v1
var v2
var v3

var acceleration = 30.0
var max_speed = 100.0
var velocity = Vector2(0,0)

# for reversing the position when the player hits an obstacle
var last_position
var last_rotation

func _init(aCoords) -> void:
	position = aCoords
	var h = a*sqrt(3)/2
	v1 = round(Vector2(-h/2, a/2))
	v2 = round(Vector2(-h/2, -a/2))
	v3 = round(Vector2(h/2, 0))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			get_parent().add_child(Bullet.new(position + v3.rotated(rotation), (get_viewport().get_mouse_position() - position).normalized()))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var mousePosition = get_viewport().get_mouse_position()
	var angle = Vector2(1,0).angle_to(mousePosition - position)
	last_rotation = rotation
	rotation = angle
	var obstacles = get_parent().obstacles
	check_collision_border(get_viewport_rect())
	for obstacle in obstacles:
		check_collision(obstacle)
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var direction = (mousePosition - position).normalized()
		velocity += acceleration * delta * direction 
		if velocity.length() > max_speed:
			velocity = velocity.normalized()*max_speed
		last_position = position
		position += velocity*delta
	elif !velocity.is_zero_approx():
		velocity = (velocity.length() - acceleration*delta)*velocity.normalized()
		last_position = position
		position += velocity*delta
	
	
func _draw():
	draw_line(v1,v2,color,wallThickness)
	draw_line(v2,v3,color,wallThickness)
	draw_line(v1,v3,color,wallThickness)
	draw_circle(v3, wallThickness, color.inverted())
	
func handle_collision(colliderPosition, vertex = null):
	#sumthing with normals
	position = last_position
	rotation = last_rotation
	velocity -= velocity*2
	
func check_collision_border(borders):
	var vertex_inside_board = func(vertexPosition):
		return borders.has_point(vertexPosition)
	for vertex in [v1,v2,v3]:
		if !vertex_inside_board.call(position+vertex):
			if borders.position.x > vertex.x or borders.end.x < vertex.x:
				handle_collision(Vector2(vertex.x,1), vertex)
			else:
				handle_collision(Vector2(1,vertex.y), vertex)
	
func check_collision(collider):
	var vertex_in_circle = func(vertexPosition):
		return collider.has_point(vertexPosition)
	for vertex in [v1,v2,v3]:
		if vertex_in_circle.call(position+vertex.rotated(rotation)):
			handle_collision(collider, vertex)
