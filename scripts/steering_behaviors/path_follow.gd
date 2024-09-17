class_name PathFollow
extends SteeringBehavior

enum Deceleration {
	SLOW = 3,
	NORMAL = 2,
	FAST = 1,
}

@export var path: Node2D
@export var loop: bool
@export var distance_to_complete: float = 10
@export var deceleration: Deceleration = Deceleration.FAST
@export var deceleration_tweeker: float = 0.3
@export var draw_points: bool
@export var draw_lines: bool

@onready var _vehicle = get_parent()

var _points: Array[Vector2]
var _current: Vector2
var _index = 0

func _ready() -> void:
	for p in path.get_children():
		_points.append(p.global_position)
	
	_current = _points[_index]


func _process(_delta: float) -> void:
	if (_current - _vehicle.global_position).length() < distance_to_complete:
		_index += 1
		if _index < _points.size():
			_current = _points[_index]
		
		elif _index == _points.size() && loop:
			_index = 0
			_current = _points[_index]

	queue_redraw()


func _draw() -> void:
	if draw_points:
		for p in _points:
			draw_circle(to_local(p), 5, Color.GREEN)
			
	if draw_lines:
		for i in _points.size() - 1:
			draw_line(to_local(_points[i]), to_local(_points[i + 1]), Color.FUCHSIA)
		
		if loop:
			draw_line(to_local(_points[_points.size() - 1]), to_local(_points[0]), Color.FUCHSIA)


func calculate() -> Vector2:
	if _current == _points[_points.size() - 1] && !loop:
		return _arrive(_current)

	return _seek(_current)


func _seek(target: Vector2) -> Vector2:
	var _desired_velocity: Vector2 = _vehicle.global_position.direction_to(target) * _vehicle.max_speed
	_vehicle.desired_velocity += _desired_velocity
	return _desired_velocity - _vehicle.velocity


func _arrive(target: Vector2) -> Vector2:
	var _to_target: Vector2 = target - _vehicle.global_position
	var _distance: float = _to_target.length()

	if _distance > 0:
		var _speed: float = _distance / (float(deceleration) * deceleration_tweeker)
		_speed = min(_speed, _vehicle.max_speed)

		var _desired_velocity: Vector2 = _to_target * _speed / _distance
		_vehicle.desired_velocity += _desired_velocity

		return _desired_velocity - _vehicle.velocity

	return Vector2.ZERO
