class_name OffsetPursuit
extends SteeringBehavior

@export var leader: Node2D
@export var offset: Vector2
@export var deceleration_tweeker: float = 0.3

@onready var _vehicle = get_parent()

func calculate() -> Vector2:
	var _offset_global = leader.to_global(offset)
	var _to_offset = _offset_global - _vehicle.global_position
	var _look_ahead_time = _to_offset.length() / (_vehicle.max_speed + leader.max_speed)
	
	return _arrive(_offset_global + leader.velocity * _look_ahead_time)


func _arrive(target: Vector2) -> Vector2:
	var _to_target: Vector2 = target - _vehicle.global_position
	var _distance: float = _to_target.length()

	if _distance > 0:
		var _speed: float = _distance / deceleration_tweeker
		_speed = min(_speed, _vehicle.max_speed)

		var _desired_velocity: Vector2 = _to_target * _speed / _distance
		_vehicle.desired_velocity += _desired_velocity

		return _desired_velocity - _vehicle.velocity

	return Vector2.ZERO
