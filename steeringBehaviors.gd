extends Node2D

class_name Steering_Behaviors

var zombie
enum Deceleration {SLOW = 1, NORMAL = 2, FAST = 3}
var forces_to_draw = {}
var hide_timer = 0
var hide_bool = true

func _init() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zombie = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	hide_timer += _delta
	if (hide_timer >= 7.0):
		if (randi_range(0,100) >= 90):
			hide_bool = !hide_bool
			hide_timer = 0
	# proper dying (but with consequences)
	#if zombie.position.distance_to(zombie.get_parent().get_child(0).position) < zombie.radius:
		#zombie.get_parent().get_child(0).queue_free()
	pass

func calculate_steering_force():
	var force_sum = Vector2.ZERO
	var player = get_node("/root/root/Player")
	var pursuit_threshold = 15
	var pursuit_radius = 100
	# code goes here
	#force_sum += _arrive(player.position, Deceleration.NORMAL)
	#force_sum += _evade(player)
	if (zombie.group_steering._get_neighbours(pursuit_radius).size() >= pursuit_threshold):
		force_sum += _pursuit(player)
	else:
		if (hide_bool):
			force_sum += _hide(player, get_node("/root/root").obstacles) * 30
		else:
			force_sum += _wander() * 0.2
	force_sum += _obstacle_avoidance(get_node("/root/root").obstacles) * 30
	force_sum += _wall_avoidance() * 10
	#if (zombie.group_steering._get_neighbours(pursuit_radius).size() >= pursuit_threshold):
		#force_sum += _pursuit(player, Color.DARK_RED)
	#else:
		##force_sum += _wander(Color.SEA_GREEN) * 0.2
		#if (hide_bool):
			#force_sum += _hide(player, get_node("/root/root").obstacles, Color.BLUE_VIOLET)
		#else:
			#force_sum += _wander(Color.SEA_GREEN) * 0.2
	#force_sum += _obstacle_avoidance(get_node("/root/root").obstacles, Color.DARK_OLIVE_GREEN) * 30
	#force_sum += _wall_avoidance(Color.SKY_BLUE) * 10
	queue_redraw()
	return force_sum

func seek(target_position, color = null):
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
		# doesnt work well if i want more forces in one color ;-;
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
		return seek(player.position);
	#Not considered ahead so we predict where the evader will be. 
	#the look-ahead time is proportional to the distance between the evader 
	#and the pursuer; and is inversely proportional to the sum of the 
	#agents' velocities 
	var look_ahead_time = to_evader.length() / (zombie.max_speed + player.velocity.length()); 
	#now seek to the predicted future position of the evader 
	#for displaying
	if color:
		forces_to_draw[color] = seek(player.position + player.velocity * look_ahead_time)
	return seek(player.position + player.velocity * look_ahead_time);

# riv - broken
func _obstacle_avoidance(obstacles, color = null):
	const MIN_BOX_LENGTH = 20
	var box_length = MIN_BOX_LENGTH + (zombie.velocity.length() / zombie.max_speed) * MIN_BOX_LENGTH
	var tagged_obstacles = []
	tagged_obstacles = _tag_obstacles_within_view_range(obstacles)
	var closest_intersecting_obstacle = null
	var dist_to_closest_obstacle = max(get_viewport_rect().size.x, get_viewport_rect().size.y) * 2 # set to smth big initially
	var local_pos_of_closest_obstacle = Vector2.ZERO
	for tagged_obstacle in tagged_obstacles:
		var local_pos = Vector2.ZERO
		local_pos = _point_to_local_space(tagged_obstacle.position, zombie.position, zombie.heading)
		if (local_pos.x >= 0):
			var expanded_radius = tagged_obstacle.radius + zombie.radius
			if (abs(local_pos.y) < expanded_radius):
				var c_x = local_pos.x;
				var c_y = local_pos.y;
				var sqrt_part = sqrt(expanded_radius * expanded_radius - c_y * c_y);
				var intersection_point = c_x - sqrt_part;
				if (intersection_point <= 0):
					intersection_point = c_x + sqrt_part;
				if (intersection_point < dist_to_closest_obstacle):
					dist_to_closest_obstacle = intersection_point;
					closest_intersecting_obstacle = tagged_obstacle;
					local_pos_of_closest_obstacle = local_pos;
	var steering_force = Vector2.ZERO
	if (closest_intersecting_obstacle):
		var steering_force_multiplier = 1.0 + (box_length - local_pos_of_closest_obstacle.x) / box_length
		# lateral force
		steering_force.y = (closest_intersecting_obstacle.radius - local_pos_of_closest_obstacle.y) * steering_force_multiplier
		const braking_weight = 0.2
		steering_force.x = (closest_intersecting_obstacle.radius - local_pos_of_closest_obstacle.x) * braking_weight
	var global_steering_vector = steering_force.rotated(zombie.heading.angle())
	if color:
		forces_to_draw[color] = global_steering_vector
	return global_steering_vector

func _tag_obstacles_within_view_range(obstacles):
	var tagged_obstacles = []
	for obstacle in obstacles:
		#if ((obstacle.position - zombie.position).length() <= zombie.obstacle_avoidance_radius):
		if ((obstacle.position - zombie.position).length() <= zombie.obstacle_avoidance_radius - obstacle.radius):
			tagged_obstacles.append(obstacle)
	return tagged_obstacles

func _point_to_local_space(point_coordinates, origin_coordinates, origin_heading):
	var local_coordinates = (point_coordinates - origin_coordinates).rotated(-origin_heading.angle())
	return local_coordinates

func _wall_avoidance(
	color = null, feeler_color_front = null,
	feeler_color_left = null, feeler_color_right = null
	):
	#get_viewport_rect()
	var feeler_length_multiplier = 8
	var feelers = [
		Vector2(8,0).rotated(zombie.heading.angle()) * feeler_length_multiplier,
		Vector2(6,0).rotated(zombie.heading.angle() - PI/4) * feeler_length_multiplier,
		Vector2(6,0).rotated(zombie.heading.angle() + PI/4) * feeler_length_multiplier
	]
	var viewport_corners = [
		Vector2.ZERO,
		Vector2(get_viewport_rect().size.x, 0),
		Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y),
		Vector2(0, get_viewport_rect().size.y)
	]
	var ip = null
	var distance_to_this_ip = 0.0
	var distance_to_closest_ip = max(
		get_viewport_rect().size.x, get_viewport_rect().size.y
		) * 2
	var closest_wall_start = null
	var closest_wall_end = null
	var closest_ip = Vector2.ZERO
	var steering_force = Vector2.ZERO
	#examine each feeler
	for feeler in feelers:
		# run through each wall checking for any intersection points
		# check if viewport has the point at the end of vector?
		for viewport_corner_id in viewport_corners.size():
			var wall_start = viewport_corners[viewport_corner_id]
			var wall_end = viewport_corners[(viewport_corner_id + 1) % 4]
			ip = Geometry2D.segment_intersects_segment(
				zombie.position, zombie.position + feeler, 
				wall_start, wall_end
				)
			if (ip):
				distance_to_this_ip = (ip - zombie.position).length()
				# keeps closest ip found so far
				if (distance_to_this_ip < distance_to_closest_ip):
					distance_to_closest_ip = distance_to_this_ip
					closest_wall_start = wall_start
					closest_wall_end = wall_end
					closest_ip = ip
		# if ip found for this feeler,
		# calculate force steering agent away from the wall
		if (closest_ip):
			# calculate by what distance the projected position of the agent
			# will overshoot the wall (Vector2)
			var overshoot = zombie.position + feeler - closest_ip
			# create a force in the direction of the wall normal, with a
			# magnitude of the overshoot
			var closest_wall_normal = (closest_wall_end - closest_wall_start).rotated(PI/2).normalized()
			# should never execute but just in case...
			if (!get_viewport_rect().has_point(closest_ip + closest_wall_normal)):
				closest_wall_normal = -closest_wall_normal
				print("flipped normal!")
			steering_force = closest_wall_normal * overshoot.length()
	if color:
		forces_to_draw[color] = steering_force
	if feeler_color_front:
		forces_to_draw[feeler_color_front] = feelers[0]
	if feeler_color_left:
		forces_to_draw[feeler_color_left] = feelers[1]
	if feeler_color_right:
		forces_to_draw[feeler_color_right] = feelers[2]
	return steering_force

# interpose() not necessary

# path_following() and offset_pursuit() not necessary


func _group_behaviors(): # nowy skrypt? rozbic na separation alignment cohesion flocking
	pass

### riv ^^^
