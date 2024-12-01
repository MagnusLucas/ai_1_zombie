extends Node2D
class_name Group_Steering

var zombies
var this_zombie
const NEIGHBOURING_RADIUS = 150

func  _ready() -> void:
	zombies = get_node("/root/root").zombies
	this_zombie = get_parent()

func _draw() -> void:
	draw_circle(Vector2i(0,0), NEIGHBOURING_RADIUS, Color.CADET_BLUE, false)

func calculate_steering_force():
	var force_sum = Vector2.ZERO
	var neighbours = _get_neighbours(NEIGHBOURING_RADIUS)
	force_sum += _cohesion(neighbours, Color.WEB_GREEN)
	#force_sum += _alignment(neighbours, Color.BLUE)
	#force_sum += _separation(neighbours, Color.RED) * 10
	return force_sum

func _get_neighbours(radius):
	zombies = get_node("/root/root").zombies
	var neighbours = []
	for zombie in zombies:
		var to : Vector2i = zombie.position - this_zombie.position
		#the bounding radius of the other is taken into account by adding it 
		#to the range
		var adjusted_range = radius + zombie.radius
		#if entity within range, collect for further consideration. (working in 
		#distance-squared space to avoid sqrts) 
		if zombie != this_zombie and to.length_squared() < adjusted_range*adjusted_range :
			neighbours.append(zombie)
	return neighbours

func _separation(neighbours, color = null):
	var SteeringForce = Vector2.ZERO
	for neighbour in neighbours:
		#make sure this agent isn't included in the calculations and that 
		#the agent being examined is close enough. --> actually this is covered in _get_neighbours
		
		var ToAgent = this_zombie.position - neighbour.position; 
		#scale the force inversely proportional to the agent's distance 
		#from its neighbor. 
		SteeringForce += ToAgent.normalized()/ToAgent.length()
	if color:
		this_zombie.steering_behaviour.forces_to_draw[color] = SteeringForce * 50
	return SteeringForce


func _alignment(neighbours, color = null):
	#used to record the average heading of the neighbors
	var AverageHeading = Vector2.ZERO
	
	#used to count the number of vehicles in the neighborhood 
	var NeighborCount = neighbours.size()
	
	#iterate through all the neighbouring vehicles and sum their heading vectors 
	for neighbour in neighbours:
		#make sure *this* agent isn't included in the calculations and that 
		#the agent being examined is close enough --> handled in _get_neighbours
		AverageHeading += neighbour.heading;
	
	#if the neighborhood contained one or more vehicles, average their 
	#heading vectors. 
	if (NeighborCount > 0):
		AverageHeading /= NeighborCount; 
		AverageHeading -= this_zombie.heading;
	if color:
		this_zombie.steering_behaviour.forces_to_draw[color] = AverageHeading * 50
	return AverageHeading

func _cohesion(neighbors, color = null):
	#first find the center of mass of all the agents 
	var CenterOfMass = Vector2.ZERO
	var SteeringForce = Vector2.ZERO
	var NeighborCount = neighbors.size()
	#iterate through the neighbors and sum up all the position vectors 
	for neighbour in neighbors:
		#make sure *this* agent isn't included in the calculations and that 
		#the agent being examined is a neighbor  --> handled in _get_neighbours
		CenterOfMass += neighbour.position
		if (NeighborCount > 0):
			#the center of mass is the average of the sum of positions 
			CenterOfMass /= NeighborCount 
			#now seek toward that position 
			SteeringForce = this_zombie.steering_behaviour.seek(CenterOfMass)
	if color:
		this_zombie.steering_behaviour.forces_to_draw[color] = SteeringForce
	return SteeringForce
