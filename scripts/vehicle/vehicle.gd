extends Node2D;
class_name Vehicle;

@export_group("Render")
@export var width: float;
@export var height: float;
@export var color: Color;
@export var show_velocity: bool;
@export var show_desired_velocity: bool;

@export_group("Simulation Properties")
@export var mass: float;
@export var max_speed: float;
@export var max_force: float;
@export var max_turn_rate: float;

@export_group("Steering Behavior")
@export var _get_automatically: bool;
@export var _steering_behaviors: Array[SteeringBehavior];

var velocity: Vector2;
var desired_velocity: Vector2;
var _heading: Vector2 = Vector2.UP;
var _side: Vector2 = Vector2.RIGHT;

func _ready() -> void:
	if _get_automatically:
		for _child in get_children():
			if _child is SteeringBehavior:
				_steering_behaviors.append(_child);


func _draw() -> void:
	var _verticies: Array[Vector2] = [Vector2(0, -height / 2 - height / 6), Vector2(width, height / 2 - height / 6), Vector2(-width, height / 2 - height / 6)];
	draw_primitive(_verticies, [color], _verticies);

	if show_desired_velocity:
		draw_line(Vector2.ZERO, desired_velocity.rotated(-rotation).limit_length(max_speed), Color(0, 0, 1, 1), 1);
		desired_velocity = Vector2.ZERO;

	if show_velocity:
		draw_line(Vector2.ZERO, velocity.rotated(-rotation), Color(0, 1, 0, 1), 1);


func _physics_process(delta: float) -> void:
	var _steering_force: Vector2 = _calculate_steering_force();

	var _acceleration: Vector2 = _steering_force / mass;
	velocity += _acceleration;
	velocity = velocity.limit_length(max_speed);

	position += velocity * delta;
	_wrap_around();

	if velocity.length_squared() > 0.00000001:
		_heading = velocity.normalized();
		_side = _heading.orthogonal();

	set_rotation(Vector2.ZERO.angle_to_point(_heading) + PI / 2);

	if show_velocity || show_desired_velocity:
		queue_redraw();


func _wrap_around() -> void:
	var _size = get_viewport_rect().size;

	if position[0] > _size[0] + height / 2:
		position[0] = -height / 2;

	if position[1] > _size[1] + height / 2:
		position[1] = -height / 2;

	if position[0] < -height / 2:
		position[0] = _size[0] + height / 2;

	if position[1] < -height / 2:
		position[1] = _size[1] + height / 2;


func _calculate_steering_force() -> Vector2:
	var _steering_force: Vector2 = Vector2.ZERO;

	for _steering_behavior in _steering_behaviors:
		_steering_force += _steering_behavior.calculate();

	_steering_force = _steering_force.limit_length(max_force);

	return _steering_force;
