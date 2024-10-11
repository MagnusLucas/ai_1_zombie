class_name Bullet
extends Sprite2D

var radius = 2;
var velocity;
var velocityMultiplier = 5
var color = Color.AQUA

func _init(aPosition, aRadius, aVelocity) -> void:
	position = aPosition
	radius = aRadius
	velocity = aVelocity * velocityMultiplier
	
func _physics_process(_delta: float) -> void:
	if !get_viewport_rect().has_point(position):
		queue_free()
	position += velocity
	var zombies = get_parent().zombies
	var obstacles = get_parent().obstacles
	for obstacle in obstacles:
		if obstacle.position.distance_to(position) <= obstacle.radius + radius:
			queue_free()
	for zombie in zombies:
		if zombie.position.distance_to(position) <= zombie.radius + radius:
			queue_free()
			get_parent().zombies.remove_at(get_parent().zombies.find(zombie))
			zombie.queue_free()
	
func _draw():
	draw_circle(Vector2i(0,0), radius, color)
