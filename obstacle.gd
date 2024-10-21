class_name Obstacle
extends Sprite2D
## This is a class representing a circular obstacle. 
## It has a radius of size between Globals.OBSTACLE_MIN_SIZE and Globals.OBSTACLE_MAX_SIZE in pixels, 
## and a color which is used when drawing it .
##
## You can call not_on_another_obstacle static function on this class to determine whether particular coordinates and radius pair
## would result in an obstacle that overlaps with another obstacle.

var radius; ## radius size of the obstacle in pixels
var color = Color.DARK_OLIVE_GREEN

## others - existing obstacles
## potential_coords - coordinates you want to check
## potential_radius - radius of obstacle you want to create at potential_coords
static func not_on_another_obstacle(others, potential_coords, potential_radius):
	for other in others:
		if other.position.distance_to(potential_coords) < other.radius + potential_radius:
			return false
	return true
	

func _init(coords, size) -> void: ##The constructor
	position = coords
	radius = size
	
func _draw():
	draw_circle(Vector2i(0,0), radius, color)

## checks if specific coordinates are inside this obstacle
func has_point(coordinates):
	if coordinates.distance_to(position) <= radius:
		return true
	return false
	
