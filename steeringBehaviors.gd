class_name Steering_Behaviors
extends Node

var zombie
enum Deceleration {SLOW = 1, NORMAL = 2, FAST = 3}

func _init() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zombie = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# proper dying (but with consequences)
	#if zombie.position.distance_to(zombie.get_parent().get_child(0).position) < zombie.radius:
		#zombie.get_parent().get_child(0).queue_free()
	pass

func calculate_steering_force():
	var force_sum = Vector2.ZERO
	var player_position = zombie.get_parent().get_child(0).position
	# code goes here
	#force_sum += seek(player_position)
	#force_sum += flee(player_position)
	force_sum += arrive(player_position, Deceleration.NORMAL)
	return force_sum

func seek(target_position):
	var desired_velocity = (target_position - zombie.position).normalized() * zombie.max_speed
	return desired_velocity - zombie.velocity

func flee(target_position):
	var panic_distance_squared = Globals.SAFE_RADIUS * Globals.SAFE_RADIUS
	var distance_to_target_squared = pow(zombie.position.distance_to(target_position), 2)
	if distance_to_target_squared > panic_distance_squared:
		return Vector2.ZERO
	var desired_velocity = (zombie.position - target_position).normalized() * zombie.max_speed
	return desired_velocity - zombie.velocity

func arrive(target_position, deceleration):
	var vector_to_target = target_position - zombie.position
	var distance_to_target = zombie.position.distance_to(target_position)
	if distance_to_target > 0:
		var deceleration_tweaker = 3
		# calculate speed required to reach the target given the desired deceleration
		var speed = distance_to_target / (deceleration * deceleration_tweaker)
		speed = min(speed, zombie.max_speed)
		var desired_velocity = vector_to_target * speed / distance_to_target
		return desired_velocity - zombie.velocity
	return Vector2.ZERO
