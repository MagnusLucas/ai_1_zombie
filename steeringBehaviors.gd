extends Node2D

class_name Steering_Behaviors

var zombie
enum Deceleration {SLOW = 1, NORMAL = 2, FAST = 3}
var forces_to_draw = {}

func _init() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zombie = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# proper dying (but with consequences)
	#if zombie.position.distance_to(zombie.get_parent().get_child(0).position) < zombie.radius:
		#zombie.get_parent().get_child(0).queue_free()
	pass

func calculate_steering_force():
	var force_sum = Vector2.ZERO
	var player = get_node("/root/root/Player")
	# code goes here
	#force_sum += _arrive(player_position, Deceleration.NORMAL)
	#force_sum += _evade(player)
	#force_sum += _hide(player, get_node("/root/root").obstacles, Color.BLUE_VIOLET)
	force_sum += _wander(Color.GREEN_YELLOW)
	queue_redraw()
	return force_sum

func _seek(target_position, color = null):
	var desired_velocity = (target_position - zombie.position).normalized() * zombie.max_speed
	
	#for displaying
	if color:
		forces_to_draw[color] =  desired_velocity - zombie.velocity
	return desired_velocity - zombie.velocity

func _flee(target_position, color = null):
	var panic_distance_squared = Globals.SAFE_RADIUS * Globals.SAFE_RADIUS
	var distance_to_target_squared = pow(zombie.position.distance_to(target_position), 2)
	if distance_to_target_squared > panic_distance_squared:
		return Vector2.ZERO
	var desired_velocity = (zombie.position - target_position).normalized() * zombie.max_speed
	
	#for displaying
	if color:
		forces_to_draw[color] =  desired_velocity - zombie.velocity
	return desired_velocity - zombie.velocity

func _arrive(target_position, deceleration, color = null):
	var vector_to_target = target_position - zombie.position
	var distance_to_target = zombie.position.distance_to(target_position)
	if distance_to_target > 0:
		var deceleration_tweaker = 3
		# calculate speed required to reach the target given the desired deceleration
		var speed = distance_to_target / (deceleration * deceleration_tweaker)
		speed = min(speed, zombie.max_speed)
		var desired_velocity = vector_to_target * speed / distance_to_target
		
		#for displaying
		if color:
			forces_to_draw[color] =  desired_velocity - zombie.velocity
		return desired_velocity - zombie.velocity
	return Vector2.ZERO

###Emi vvv

func _evade(player, color = null):
	var to_player = player.position - zombie.position
	#the look-ahead time is proportional to the distance between the pursuer
	#and the evader; and is inversely proportional to the sum of the
	#agents' velocities
	var look_ahead_time = to_player.length()/(zombie.max_speed + player.velocity.length())
	#flee away from predicted future position of the pursuer
	#for displaying
	if color:
		forces_to_draw[color] = _flee(player.position + player.velocity * look_ahead_time )
	return _flee(player.position + player.velocity * look_ahead_time )

func _get_hiding_position(obastacle_position, obstacle_radius, target_position):
	#calculate how far away the agent is to be from the chosen obstacle’s bounding radius
	const distance_from_boundary = 30.0;
	var dist_away = obstacle_radius + distance_from_boundary
	#calculate the heading toward the object from the target
	var to_obstacle = (obastacle_position - target_position).normalized()
	#scale it to size and add to the obstacle's position to get
	#the hiding spot.
	return (to_obstacle * dist_away) + obastacle_position
	
	
func _hide(player, obstacles, color = null):
	var best_hiding_spot
	var hiding_spot
	var dist 
	var max_value = pow((get_viewport_rect().size.x + get_viewport_rect().size.y) * 2, 2)
	var dist_to_closest = max_value
	for obstacle in obstacles:
		#calculate the position of the hiding spot for this obstacle
		hiding_spot = _get_hiding_position(obstacle.position, obstacle.radius, player.position) 
		#work in distance-squared space to find the closest hiding
		#spot to the agent
		dist = hiding_spot.distance_squared_to(zombie.position)
		if(dist<dist_to_closest):
			dist_to_closest = dist
			best_hiding_spot = hiding_spot
	#end for
	#if no suitable obstacles found then evade the target
	if (dist_to_closest == max_value):
		#for displaying
		if color:
			forces_to_draw[color] = _evade(player)
		return _evade(player)
	#else use Arrive on the hiding spot
	#for displaying
	if color:
		forces_to_draw[color] = _arrive(best_hiding_spot, Deceleration.FAST)
	return _arrive(best_hiding_spot, Deceleration.FAST)



###Emi ^^^

###me vvv

const WANDER_RADIUS = 10.0
var wander_target = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * WANDER_RADIUS #local target

func _wander(color = null):
	# if they spin in place increase wander distance/decrease wander radius
	const WANDER_DISTANCE = 20.0
	#if they keep going the same direction decrease jitter
	const WANDER_JITTER = 1.0

	wander_target += Vector2(randf_range(-1,1) * WANDER_JITTER, randf_range(-1,1) * WANDER_JITTER)
	wander_target = wander_target.normalized()
	wander_target *= WANDER_RADIUS
	
	var target_local = wander_target + Vector2(WANDER_DISTANCE,0)
	
	#changing the target to world space
	var target_world = zombie.position + target_local.rotated(zombie.heading.angle())
	
	#for displaying
	if color:
		forces_to_draw[color] = target_world - zombie.position
	return target_world - zombie.position

func _draw_force(force, color):
	draw_line(Vector2.ZERO, force, color, 3)

func _draw():
	for color in forces_to_draw:
		_draw_force(forces_to_draw[color], color)

### me ^^^

### riv vvv

func _pursuit(player, color = null):
	#if the evader is ahead and facing the agent then we can just seek
	#for the evader's current position. 
	var to_evader = player.position - zombie.position; 
	var relative_heading = zombie.heading.dot(player.heading); 
	if ((to_evader.dot(zombie.heading) > 0) and (relative_heading < -0.95)):
	#acos(0.95)=18 degs 
		return _seek(player.position);
	#Not considered ahead so we predict where the evader will be. 
	#the look-ahead time is proportional to the distance between the evader 
	#and the pursuer; and is inversely proportional to the sum of the 
	#agents' velocities 
	var look_ahead_time = to_evader.length() / (zombie.max_speed + player.velocity.length()); 
	#now seek to the predicted future position of the evader 
	#for displaying
	if color:
		forces_to_draw[color] = _seek(player.position + player.velocity * look_ahead_time)
	return _seek(player.position + player.velocity * look_ahead_time);


func _obstacle_avoidance(obstacles): # riv
	const MIN_BOX_LENGTH = 10
	# the detection box length is proportional to the agent's velocity
	var box_length = MIN_BOX_LENGTH + (zombie.velocity.length() / zombie.max_speed) * MIN_BOX_LENGTH
	# tag all obstacles within range of the box for processing
	
	# this will keep track of the closest intersecting obstacle (CIB)
	

func _wall_avoidance():
	pass

# interpose() not necessary

# path_following() and offset_pursuit() not necessary


func _group_behaviors(): # nowy skrypt? rozbic na separation alignment cohesion flocking
	pass

### riv ^^^
