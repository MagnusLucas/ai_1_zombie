class_name Bullet
extends Sprite2D

var direction_vector
var color = Color.AQUA
var ray_end_point #global position of the end of the bullet
var lifetime = 3 #fps
var ray_width = 2

func _init(bullet_position, bullet_direction) -> void:
	position = bullet_position
	direction_vector = bullet_direction
	ray_end_point = position + direction_vector
	
func _ready() -> void:
	_rayCast()
	
func _process(_delta: float) -> void:
	if lifetime <= 0:
		queue_free()
	else:
		lifetime -= 1
	
func _draw():
	# line is drawn at the position of this sprite, so its beginning is at Vector2i(0,0) 
	# and rayEndPoint is global, so position needs to be distracted
	draw_line(Vector2i(0,0), ray_end_point - position, color, ray_width)
	
func _rayCast():
	var colliding = false
	while get_viewport_rect().has_point(ray_end_point) and not colliding:
		ray_end_point += direction_vector
		# we should probably be checking only zombies and obstacles that are close, but for now it is what it is
		var zombies = get_parent().zombies
		var obstacles = get_parent().obstacles
		for obstacle in obstacles:
			if obstacle.has_point(ray_end_point):
				colliding = true
		for zombie in zombies:
			if zombie.has_point(ray_end_point):
				colliding = true
