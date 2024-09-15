class_name Seek
extends SteeringBehavior

@export var target_node: Node2D

@onready var _vehicle = get_parent()

func calculate() -> Vector2:
	var _desired_velocity: Vector2 = _vehicle.position.direction_to(target_node.global_position) * _vehicle.max_speed
	_vehicle.desired_velocity += _desired_velocity
	return _desired_velocity - _vehicle.velocity
