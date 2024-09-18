class_name Alignment
extends SteeringBehavior

@export var radius: float
@export var show_radius: bool

@onready var _vehicle: Vehicle = get_parent()
@onready var _vehicles: Array[Vehicle] = _get_all_vehicles()

# just for testing
func _ready() -> void:
	_vehicle._heading = Vector2(100, 0)


func _draw() -> void:
	if show_radius:
		draw_circle(Vector2.ZERO, radius, Color(0, .8, 1, .3))


func calculate() -> Vector2:
	var _neighbors: Array[Vehicle]
	for v in _vehicles:
		if radius >= _vehicle.global_position.distance_to(v.global_position):
			_neighbors.append(v)
	
	var _average_heading = Vector2.ZERO
	for n in _neighbors:
		_average_heading += n._heading
	
	if _neighbors.size() > 0:
		_average_heading /= _neighbors.size()
		_average_heading -= _vehicle._heading
	
	return _average_heading


# not the best way but it works
func _get_all_vehicles(node = get_tree().root, listOfAllNodesInTree: Array[Vehicle] = []):
	if node is Vehicle && node != _vehicle:
		listOfAllNodesInTree.append(node as Vehicle)
	for childNode in node.get_children():
		_get_all_vehicles(childNode, listOfAllNodesInTree)
	return listOfAllNodesInTree
