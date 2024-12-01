class_name Bullet
extends Sprite2D

var directionVector
var color = Color.AQUA
var rayEndPoint #global position of the end of the bullet
var lifetime = 3 #fps
var rayWidth = 2

func _init(aPosition, aDirection) -> void:
	position = aPosition
	directionVector = aDirection
	rayEndPoint = position + directionVector
	
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
	draw_line(Vector2i(0,0), rayEndPoint - position, color, rayWidth)
	
func _rayCast():
	var colliding = false
	while get_viewport_rect().has_point(rayEndPoint) and not colliding:
		rayEndPoint += directionVector
		# we should probably be checking only zombies and obstacles that are close, but for now it is what it is
		var zombies = get_parent().zombies
		var obstacles = get_parent().obstacles
		for obstacle in obstacles:
			if obstacle.has_point(rayEndPoint):
				colliding = true
		for zombie in zombies:
			if zombie.has_point(rayEndPoint):
				colliding = true
