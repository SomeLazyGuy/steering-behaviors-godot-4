class_name Evade
extends SteeringBehavior

@export var target_node: Node2D
@export var panic_radius: float:
	set(value):
		panic_radius = value
		queue_redraw()
@export var show_panic_radius: bool
@export var show_predicted_position: bool

@onready var _vehicle = get_parent()
@onready var _predicted_position: Vector2 = target_node.global_position

func _draw() -> void:
	if show_panic_radius:
		draw_arc(Vector2.ZERO, panic_radius, 0, 2 * PI, 360, Color(0, 0, 1, 1))

	if show_predicted_position:
		draw_circle(_vehicle.to_local(_predicted_position), 5, Color.RED)


func calculate() -> Vector2:
	if !(target_node is Vehicle):
		return _flee(target_node.global_position)

	var _to_target: Vector2 = target_node.global_position - _vehicle.global_position;
	var _look_ahead_time: float = _to_target.length() / (_vehicle.max_speed + target_node.velocity.length());
	_predicted_position = target_node.global_position + target_node.velocity * _look_ahead_time;

	return _flee(_predicted_position)

func _flee(target: Vector2) -> Vector2:
	var _to_target: Vector2 = _vehicle.global_position - target
	var _distance: float = _to_target.length()

	if _distance < panic_radius || panic_radius < 0:
		var _desired_velocity: Vector2 = _to_target / _distance * _vehicle.max_speed;
		_vehicle.desired_velocity += _desired_velocity;
		return _desired_velocity - _vehicle.velocity;

	return Vector2.ZERO;
