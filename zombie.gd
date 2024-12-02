class_name Zombie
extends Sprite2D

static var radius = 10;
var color = Color.DARK_RED
var filled = true

var velocity = Vector2(0,0)
var heading = velocity.normalized()
var side = heading.rotated(PI/2)

var mass = 1
var max_speed = 30
var max_force = 10
var max_turn_rate = 10 #rad/s

var steering_behaviour
var group_steering

static func not_on_obstacle_or_zombie(obstacles, zombies, potential_coords):
	for obstacle in obstacles:
		if obstacle.position.distance_to(potential_coords) < obstacle.radius + radius:
			return false
	for zombie in zombies:
		if zombie.position.distance_to(potential_coords) < radius * 2:
			return false
	return true

func _init(coords, zombie_name = null) -> void:
	position = coords
	if zombie_name:
		name = zombie_name

func _ready() -> void:
	steering_behaviour = Steering_Behaviors.new()
	add_child(steering_behaviour)
	group_steering = Group_Steering.new()
	add_child(group_steering)

func _physics_process(delta: float) -> void:
	var acceleration = (steering_behaviour.calculate_steering_force() + group_steering.calculate_steering_force())/mass
	# update velocity
	velocity += acceleration * delta
	velocity = velocity.limit_length(max_speed)
	# update position
	position += velocity * delta
	
	if not velocity.is_zero_approx():
		heading = velocity.normalized()
		side = heading.rotated(PI/2)

func _draw():
	draw_circle(Vector2i(0,0), radius, color)
	
## checks if specific coordinates are inside this zombie
func has_point(coordinates):
	if coordinates.distance_to(position) <= radius:
		get_parent().zombies.remove_at(get_parent().zombies.find(self))
		queue_free()
		return true
	return false
