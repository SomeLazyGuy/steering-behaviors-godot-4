class_name Interpose
extends SteeringBehavior

@export var target1: Node2D
@export var target2: Node2D
@export var show_visuals: bool
@export var deceleration_tweeker: float = 0.3;

@onready var _vehicle: Vehicle = get_parent()

var _mid_point: Vector2
var _prediction1: Vector2
var _prediction2: Vector2

func _draw() -> void:
	if show_visuals:
		draw_line(to_local(_prediction1), to_local(_prediction2), Color.FUCHSIA)
		draw_circle(to_local(_mid_point), 5, Color.GREEN)
		
		if _prediction1 != target1.global_position:
			draw_circle(to_local(_prediction1), 5, Color.GREEN)
			
		if _prediction2 != target2.global_position:
			draw_circle(to_local(_prediction2), 5, Color.GREEN)


func _process(_delta: float) -> void:
	queue_redraw()


func calculate() -> Vector2:
	_mid_point = (target1.global_position + target2.global_position) / 2
	var _distance_to_mid = _vehicle.global_position.distance_to(_mid_point)
	var _time_to_mid = _distance_to_mid / _vehicle.max_speed
	
	_prediction1 = target1.global_position
	if target1 is Vehicle:
		var _velocity = target1.to_global(target1.velocity.rotated(-target1.rotation)) - target1.global_position
		_prediction1 = target1.global_position + _velocity
	
	_prediction2 = target2.global_position
	if target2 is Vehicle:
		var _velocity = target2.to_global(target2.velocity.rotated(-target2.rotation)) - target2.global_position
		_prediction2 = target2.global_position + _velocity
		
	_mid_point = (_prediction1 + _prediction2) / 2
	
	return _arrive(_mid_point)


func _arrive(target: Vector2) -> Vector2:
	var _to_target: Vector2 = target - _vehicle.global_position;
	var _distance: float = _to_target.length();

	if _distance > 0:
		var _speed: float = _distance / deceleration_tweeker;
		_speed = min(_speed, _vehicle.max_speed);

		var _desired_velocity: Vector2 = _to_target * _speed / _distance;
		_vehicle.desired_velocity += _desired_velocity;

		return _desired_velocity - _vehicle.velocity;

	return Vector2.ZERO;
