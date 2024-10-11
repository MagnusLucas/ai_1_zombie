class_name Obstacle
extends Sprite2D

var radius;
var color = Color.DARK_OLIVE_GREEN
var filled = false

static func not_on_another_obstacle(others, potential_coords, potential_radius):
	for other in others:
		if other.position.distance_to(potential_coords) < other.radius + potential_radius:
			return false
	return true

func _init(coords, size) -> void:
	position = coords
	radius = size
	
func _draw():
	draw_circle(Vector2i(0,0), radius, color, filled, 5)
