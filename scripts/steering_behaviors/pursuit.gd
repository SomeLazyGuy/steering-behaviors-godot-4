class_name Pursuit
extends SteeringBehavior

@export var target_node: Node2D
@export var show_predicted_position: bool

@onready var _vehicle = get_parent()
@onready var _predicted_position: Vector2 = target_node.global_position

func _draw() -> void:
	draw_circle(_vehicle.to_local(_predicted_position), 5, Color.BLUE);


func calculate() -> Vector2:
	if !(target_node is Vehicle):
		return _seek(target_node.global_position);

	var _to_target: Vector2 = target_node.global_position - _vehicle.global_position;
	var _relative_heading: float = _vehicle._heading.dot(target_node._heading);

	if _to_target.dot(_vehicle._heading) > 0 && _relative_heading < -0.95:
		return _seek(target_node.global_position);

	var _look_ahead_time: float = _to_target.length() / (_vehicle.max_speed + target_node.velocity.length());
	_predicted_position = target_node.global_position + target_node.velocity * _look_ahead_time;

	return _seek(_predicted_position);


func _seek(target: Vector2) -> Vector2:
	var _desired_velocity: Vector2 = _vehicle.position.direction_to(target) * _vehicle.max_speed
	_vehicle.desired_velocity += _desired_velocity
	return _desired_velocity - _vehicle.velocity
