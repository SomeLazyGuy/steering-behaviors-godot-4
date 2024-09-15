class_name Flee
extends SteeringBehavior

@export var target_node: Node2D
@export var panic_radius: float:
	set(value):
		panic_radius = value
		queue_redraw()
@export var show_panic_radius: bool

@onready var _vehicle = get_parent()

func _draw() -> void:
	if show_panic_radius:
		draw_arc(Vector2.ZERO, panic_radius, 0, 2 * PI, 360, Color(0, 0, 1, 1)); 

func calculate() -> Vector2:
	var _to_target: Vector2 = _vehicle.global_position - target_node.global_position;
	var _distance: float = _to_target.length();

	if _distance < panic_radius || panic_radius < 0:
		var _desired_velocity: Vector2 = _to_target / _distance * _vehicle.max_speed;
		_vehicle.desired_velocity += _desired_velocity;
		return _desired_velocity - _vehicle.velocity;

	return Vector2.ZERO;
