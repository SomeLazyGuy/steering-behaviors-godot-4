class_name Seperation
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
	
	var _steering_force = Vector2.ZERO
	for n in _neighbors:
		var _to_agent = _vehicle.global_position - n.global_position
		_steering_force += _to_agent.normalized() / _to_agent.length()
	
	return _steering_force


# not the best way but it works
func _get_all_vehicles(node = get_tree().root, listOfAllNodesInTree: Array[Vehicle] = []):
	if node is Vehicle && node != _vehicle:
		listOfAllNodesInTree.append(node as Vehicle)
	for childNode in node.get_children():
		_get_all_vehicles(childNode, listOfAllNodesInTree)
	return listOfAllNodesInTree
