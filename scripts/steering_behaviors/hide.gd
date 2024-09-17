class_name Hide
extends SteeringBehavior

@export var target: Node2D
@export var distance_from_boundary: float = 30
@export var deceleration_tweeker: float = 0.3
@export var show_hiding_spots: bool
@export var draw_lines: bool

@onready var _vehicle = get_parent()
@onready var _obstacles = $"../../Obstacles".get_children()

var _hiding_spots: Array[Vector2]

func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if show_hiding_spots:
		for h in _hiding_spots:
			draw_circle(to_local(h), 5, Color.GREEN)

	if draw_lines:
		for h in _hiding_spots:
			draw_line(to_local(target.global_position), to_local(h), Color.FUCHSIA)


func calculate() -> Vector2:
	_hiding_spots.clear()
	
	for o in _obstacles:
		var _direction = (o.global_position - target.global_position).normalized()
		_hiding_spots.append(o.global_position + _direction * (o.radius + distance_from_boundary))
	
	var _closest_distance: float = INF
	var _closest_hiding_spot: Vector2
	
	for h in _hiding_spots:
		var _distance = (h - _vehicle.global_position).length()
		if _distance < _closest_distance:
			_closest_distance = _distance
			_closest_hiding_spot = h
	
	if _closest_hiding_spot:
		return _arrive(_closest_hiding_spot)
	
	return Vector2.ZERO


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
