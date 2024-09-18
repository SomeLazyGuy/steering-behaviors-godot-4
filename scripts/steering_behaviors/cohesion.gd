class_name Cohesion
extends SteeringBehavior

@export var radius: float
@export var show_radius: bool

@onready var _vehicle: Vehicle = get_parent()
@onready var _vehicles: Array[Vehicle] = _get_all_vehicles()


func _draw() -> void:
	if show_radius:
		draw_circle(Vector2.ZERO, radius, Color(0, .8, 1, .3))


func calculate() -> Vector2:
	var _neighbors: Array[Vehicle]
	for v in _vehicles:
		if radius >= _vehicle.global_position.distance_to(v.global_position):
			_neighbors.append(v)
	
	var _center_of_mass = Vector2.ZERO
	for n in _neighbors:
		_center_of_mass += n.global_position
	
	var _steering_force = Vector2.ZERO
	if _neighbors.size() > 0:
		_center_of_mass /= _neighbors.size()
		_steering_force = _seek(_center_of_mass)
	
	return _steering_force


# not the best way but it works
func _get_all_vehicles(node = get_tree().root, listOfAllNodesInTree: Array[Vehicle] = []):
	if node is Vehicle && node != _vehicle:
		listOfAllNodesInTree.append(node as Vehicle)
	for childNode in node.get_children():
		_get_all_vehicles(childNode, listOfAllNodesInTree)
	return listOfAllNodesInTree


func _seek(target: Vector2) -> Vector2:
	var _desired_velocity: Vector2 = _vehicle.position.direction_to(target) * _vehicle.max_speed
	_vehicle.desired_velocity += _desired_velocity
	return _desired_velocity - _vehicle.velocity
