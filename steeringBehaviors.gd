class_name Steering_Behaviors
extends Node

var zombie

func _init() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zombie = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# proper dying (but with consequences)
	if zombie.position.distance_to(zombie.get_parent().get_child(0).position) < zombie.radius:
		zombie.get_parent().get_child(0).queue_free()

func calculate_steering_force():
	var force_sum = Vector2.ZERO
	var player_position = zombie.get_parent().get_child(0).position
	# code goes here
	force_sum += seek(player_position)
	return force_sum

func seek(target_position):
	var desired_velocity = (target_position - zombie.position).normalized() * zombie.max_speed
	return desired_velocity - zombie.velocity

func flee(target_position): # add panic distance
	var desired_velocity = (zombie.position - target_position).normalized() * zombie.max_speed
	return desired_velocity - zombie.velocity
