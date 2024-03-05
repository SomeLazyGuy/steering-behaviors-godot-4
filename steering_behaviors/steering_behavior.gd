@tool
extends Node2D;
class_name SteeringBehavior;

enum SteeringBehaviorType {
	SEEK,
	FLEE,
	ARRIVE,
	PURSUIT,
	EVADE,
	WANDER,
}

enum Deceleration {
	SLOW = 1,
	NORMAL = 2,
	FAST = 3,
}

## Target the agent will use for force calculations
@export var target_node: Node2D;

var _type: SteeringBehaviorType;

# flee
var _panic_radius: float;
var _show_panic_radius: bool;

# arrive
var _deceleration: Deceleration;
var _deceleration_tweeker: float = 0.3;

# pursuit
var _predicted_position: Vector2;
var _show_predicted_position: bool;

# wander
var _wander_target: Vector2;
var _wander_radius: float;
var _wander_distance: float;
var _wander_jitter: float;
var _show_visuals: float;

@onready var _vehicle: Vehicle = get_parent();

func _get(property: StringName):
	if property == "/type":
		return _type;

	if property.ends_with("/panic_radius"):
		return _panic_radius;

	if property.ends_with("/show_panic_radius"):
		return _show_panic_radius;

	if property == "/arrive/deceleration":
		return _deceleration;

	if property == "/arrive/deceleration_tweeker":
		return _deceleration_tweeker;

	if property.ends_with("/show_predicted_position"):
		return _show_predicted_position;

	if property == "/wander/wander_radius":
		return _wander_radius;

	if property == "/wander/wander_distance":
		return _wander_distance;

	if property == "/wander/wander_jitter":
		return _wander_jitter;

	if property == "/wander/show_visuals":
		return _show_visuals;


func _set(property: StringName, value: Variant) -> bool:
	if property == "/type":
		_type = value;

		if _type == SteeringBehaviorType.EVADE:
			_panic_radius = -1;

		notify_property_list_changed()

	if property.ends_with("/panic_radius"):
		_panic_radius = value;

	if property.ends_with("/show_panic_radius"):
		_show_panic_radius = value;

	if property == "/arrive/deceleration":
		_deceleration = value;

	if property == "/arrive/deceleration_tweeker":
		_deceleration_tweeker = value;

	if property.ends_with("/show_predicted_position"):
		_show_predicted_position = value;

	if property == "/wander/wander_radius":
		_wander_radius = value;

	if property == "/wander/wander_distance":
		_wander_distance = value;

	if property == "/wander/wander_jitter":
		_wander_jitter = value;

	if property == "/wander/show_visuals":
		_show_visuals = value;

	return true


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(SteeringBehaviorType.keys()),
		"name": "/type",
		"type": TYPE_INT,
	})

	if _type == SteeringBehaviorType.FLEE:
		property_list.append({
			"name": "/flee/panic_radius",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "-1,2000,or_greater",
		})

		property_list.append({
			"name": "/flee/show_panic_radius",
			"type": TYPE_BOOL,
		})

	if _type == SteeringBehaviorType.ARRIVE:
		property_list.append({
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(Deceleration.keys()),
			"name": "/arrive/deceleration",
			"type": TYPE_INT,
		})

		property_list.append({
			"name": "/arrive/deceleration_tweeker",
			"type": TYPE_FLOAT,
		})

	if _type == SteeringBehaviorType.PURSUIT:
		property_list.append({
			"name": "/pursuit/show_predicted_position",
			"type": TYPE_BOOL,
		})

	if _type == SteeringBehaviorType.EVADE:
		property_list.append({
			"name": "/evade/panic_radius",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "-1,2000,or_greater",
		})

		property_list.append({
			"name": "/evade/show_panic_radius",
			"type": TYPE_BOOL,
		})

		property_list.append({
			"name": "/evade/show_predicted_position",
			"type": TYPE_BOOL,
		})

	if _type == SteeringBehaviorType.WANDER:
		property_list.append({
			"name": "/wander/wander_radius",
			"type": TYPE_FLOAT,
		})

		property_list.append({
			"name": "/wander/wander_distance",
			"type": TYPE_FLOAT,
		})

		property_list.append({
			"name": "/wander/wander_jitter",
			"type": TYPE_FLOAT,
		})

		property_list.append({
			"name": "/wander/show_visuals",
			"type": TYPE_BOOL,
		})

	return property_list


func _draw() -> void:
	if _show_panic_radius:
		draw_arc(Vector2.ZERO, _panic_radius, 0, 2 * PI, 360, Color(0, 0, 1, 1));

	if _show_predicted_position:
		var _color: Color;
		if _type == SteeringBehaviorType.PURSUIT:
			_color = Color(0, 1, 0, 1);
		else:
			_color = Color(1, 0, 0, 1);

		draw_circle(to_local(_predicted_position), 5, _color);

	if _show_visuals:
		draw_arc(Vector2.UP * _wander_distance, _wander_radius, 0, 2 * PI, 360, Color(0, 0, 1, 1));
		draw_circle(_wander_target, 5, Color(0, 1, 0, 1));


func _process(_delta: float) -> void:
	if _show_panic_radius || _show_predicted_position || _show_visuals:
		queue_redraw();


func calculate() -> Vector2:
	match _type:
		SteeringBehaviorType.SEEK:
			return _seek(target_node.position);

		SteeringBehaviorType.FLEE:
			return _flee(target_node.position);

		SteeringBehaviorType.ARRIVE:
			return _arrive(target_node.position);

		SteeringBehaviorType.PURSUIT:
			return _pursuit(target_node.position);

		SteeringBehaviorType.EVADE:
			return _evade(target_node.position);

		SteeringBehaviorType.WANDER:
			return _wander();

		_:
			return Vector2.ZERO;


func _seek(target: Vector2) -> Vector2:
	var _desired_velocity: Vector2 = _vehicle.position.direction_to(target) * _vehicle.max_speed;
	_vehicle.desired_velocity += _desired_velocity;
	return _desired_velocity - _vehicle.velocity;


func _flee(target: Vector2) -> Vector2:
	var _to_target: Vector2 = _vehicle.position - target;
	var _distance: float = _to_target.length();

	if _distance < _panic_radius || _panic_radius < 0:
		var _desired_velocity: Vector2 = _to_target / _distance * _vehicle.max_speed;
		_vehicle.desired_velocity += _desired_velocity;
		return _desired_velocity - _vehicle.velocity;

	return Vector2.ZERO;


func _arrive(target: Vector2) -> Vector2:
	var _to_target: Vector2 = target - _vehicle.position;
	var _distance: float = _to_target.length();

	if _distance > 0:
		var _speed: float = _distance / (float(_deceleration) * _deceleration_tweeker);
		_speed = min(_speed, _vehicle.max_speed);

		var _desired_velocity: Vector2 = _to_target * _speed / _distance;
		_vehicle.desired_velocity += _desired_velocity;

		return _desired_velocity - _vehicle.velocity;

	return Vector2.ZERO;


func _pursuit(target: Vector2) -> Vector2:
	if !(target_node is Vehicle):
		return _seek(target);

	var _to_target: Vector2 = target - _vehicle.position;
	var _relative_heading: float = _vehicle._heading.dot(target_node._heading);

	if _to_target.dot(_vehicle._heading) > 0 && _relative_heading < -0.95:
		return _seek(target);

	var _look_ahead_time: float = _to_target.length() / (_vehicle.max_speed + target_node.velocity.length());
	_predicted_position = target + target_node.velocity * _look_ahead_time;

	return _seek(_predicted_position);


func _evade(target: Vector2) -> Vector2:
	if !(target_node is Vehicle):
		return _flee(target);

	var _to_target: Vector2 = target - _vehicle.position;
	var _look_ahead_time: float = _to_target.length() / (_vehicle.max_speed + target_node.velocity.length());
	_predicted_position = target + target_node.velocity * _look_ahead_time;

	return _flee(_predicted_position);


func _wander() -> Vector2:
	_wander_target += Vector2(randf_range(-1, 1) * _wander_jitter, randf_range(-1, 1) * _wander_jitter);
	_wander_target = _wander_target.normalized() * _wander_radius;
	_wander_target += Vector2.UP * _wander_distance;

	return to_global(_wander_target) - _vehicle.position;
