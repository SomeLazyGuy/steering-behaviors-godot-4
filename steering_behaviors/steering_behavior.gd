@tool
extends Node2D;
class_name SteeringBehavior;

enum SteeringBehaviorType {
	SEEK,
	FLEE,
	ARRIVE,
}

enum Deceleration {
	SLOW = 1,
	NORMAL = 2,
	FAST = 3,
}

## Target the agent will use for force calculations
@export var target: Node2D;

var _type: SteeringBehaviorType;
var _deceleration: Deceleration;
var _deceleration_tweeker: float = 0.3;
var _panic_radius: float = 100;

@onready var _vehicle: Vehicle = get_parent();

func _get(property: StringName):
	if property == "/type":
		return _type;

	if property == "/flee/panic_radius":
		return _panic_radius;

	if property == "/arrive/deceleration":
		return _deceleration;

	if property == "/arrive/deceleration_tweeker":
		return _deceleration_tweeker;


func _set(property: StringName, value: Variant):
	if property == "/type":
		_type = value;
		notify_property_list_changed()

	if property == "/flee/panic_radius":
		_panic_radius = value;

	if property == "/arrive/deceleration":
		_deceleration = value;

	if property == "/arrive/deceleration_tweeker":
		_deceleration_tweeker = value;

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

	return property_list


func calculate() -> Vector2:
	match _type:
		SteeringBehaviorType.SEEK:
			return _seek();

		SteeringBehaviorType.FLEE:
			return _flee();

		SteeringBehaviorType.ARRIVE:
			return _arrive();

		_:
			return Vector2.ZERO;


func _seek() -> Vector2:
	var _desired_velocity: Vector2 = _vehicle.position.direction_to(target.position) * _vehicle.max_speed;
	_vehicle.desired_velocity = _desired_velocity;
	return _desired_velocity - _vehicle.velocity;


func _flee() -> Vector2:
	var _desired_velocity: Vector2 = target.position.direction_to(_vehicle.position) * _vehicle.max_speed;
	_vehicle.desired_velocity = _desired_velocity;
	return _desired_velocity - _vehicle.velocity;


func _arrive() -> Vector2:
	var _to_target: Vector2 = target.position - _vehicle.position;
	var _distance: float = _to_target.length();

	if _distance > 0:
		var _speed: float = _distance / (float(_deceleration) * _deceleration_tweeker);
		_speed = min(_speed, _vehicle.max_speed);

		var _desired_velocity: Vector2 = _to_target * _speed / _distance;
		_vehicle.desired_velocity = _desired_velocity;

		return _desired_velocity - _vehicle.velocity;

	return Vector2.ZERO;
