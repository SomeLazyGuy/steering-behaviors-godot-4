class_name Arrive
extends SteeringBehavior

enum Deceleration {
	SLOW = 3,
	NORMAL = 2,
	FAST = 1,
}

@export var target_node: Node2D
@export var deceleration: Deceleration;
@export var deceleration_tweeker: float = 0.3;

@onready var _vehicle = get_parent()

func calculate() -> Vector2:
	var _to_target: Vector2 = target_node.global_position - _vehicle.global_position;
	var _distance: float = _to_target.length();

	if _distance > 0:
		var _speed: float = _distance / (float(deceleration) * deceleration_tweeker);
		_speed = min(_speed, _vehicle.max_speed);

		var _desired_velocity: Vector2 = _to_target * _speed / _distance;
		_vehicle.desired_velocity += _desired_velocity;

		return _desired_velocity - _vehicle.velocity;

	return Vector2.ZERO;
