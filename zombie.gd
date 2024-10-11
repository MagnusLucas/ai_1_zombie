class_name Zombie
extends Sprite2D

static var radius = 10;
var color = Color.DARK_RED
var filled = true

static func not_on_obstacle_or_zombie(obstacles, zombies, potential_coords):
	for obstacle in obstacles:
		if obstacle.position.distance_to(potential_coords) < obstacle.radius + radius:
			return false
	for zombie in zombies:
		if zombie.position.distance_to(potential_coords) < radius * 2:
			return false
	return true

func _init(coords) -> void:
	position = coords
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _draw():
	draw_circle(Vector2i(0,0), radius, color)
