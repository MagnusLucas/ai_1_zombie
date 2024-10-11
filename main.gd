extends Node2D

var obstacles = []
var zombies = []
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = Player.new(get_viewport_rect().size/2)
	add_child(player)
	for i in range(Globals.OBSTACLE_COUNT):
		create_obstacle()
	for i in range(Globals.ZOMBIE_COUNT):
		create_zombie()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if randi_range(0,59) == 0:
		create_zombie()

func is_not_on_player(potential_coords, radius):
	if potential_coords.distance_to(player.position) < radius + Globals.SAFE_RADIUS:
		return false
	return true

func create_obstacle():
	var window_size = get_viewport_rect().size
	var coords = Vector2i(randi_range(0, window_size.x-1),randi_range(0, window_size.y-1))
	var radius = randi_range(Globals.OBSTACLE_MIN_SIZE, Globals.OBSTACLE_MAX_SIZE)
	while !(Obstacle.not_on_another_obstacle(obstacles, coords, radius) and is_not_on_player(coords, radius)):
		coords = Vector2i(randi_range(0, window_size.x-1),randi_range(0, window_size.y-1))
		radius = randi_range(Globals.OBSTACLE_MIN_SIZE, Globals.OBSTACLE_MAX_SIZE)
	var obstacle = Obstacle.new(coords, radius)
	obstacles.append(obstacle)
	add_child(obstacle)
	
func create_zombie():
	var window_size = get_viewport_rect().size
	var coords = Vector2i(randi_range(0+Zombie.radius, window_size.x-1-Zombie.radius),randi_range(0+Zombie.radius, window_size.y-1-Zombie.radius))
	while !(Zombie.not_on_obstacle_or_zombie(obstacles, zombies, coords) and is_not_on_player(coords, Zombie.radius)):
		coords = Vector2i(randi_range(0+Zombie.radius, window_size.x-1-Zombie.radius),randi_range(0+Zombie.radius, window_size.y-1-Zombie.radius))
	var zombie = Zombie.new(coords)
	zombies.append(zombie)
	add_child(zombie)
