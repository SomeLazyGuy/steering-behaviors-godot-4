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
	OBSTACLE_AVOIDANCE,
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

var _show_visuals: float;

# wander
var _wander_target: Vector2;
var _wander_radius: float;
var _wander_distance: float;
var _wander_jitter: float;

# obstacle avoidance
var _min_detection_box_length: float;
var _detection_box_length: float;
var _area2d: Area2D;
var _collision_shape2d: CollisionShape2D;
var _rectangle_shape2d: RectangleShape2D;
var _obstacles: Array[Obstacle];

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
		
	if property == "/wander/show_visuals":
		return _show_visuals;

	if property == "/obstacles/show_visuals":
		return _show_visuals;
		
	if property == "/obstacles/min_detection_box_length":
		return _min_detection_box_length;


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
		
	if property == "/obstacles/show_visuals":
		_show_visuals = value;
		
	if property == "/obstacles/min_detection_box_length":
		_min_detection_box_length = value;

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
		
	if _type == SteeringBehaviorType.OBSTACLE_AVOIDANCE:
		property_list.append({
			"name": "/obstacles/show_visuals",
			"type": TYPE_BOOL,
		})
		
		property_list.append({
			"name": "/obstacles/min_detection_box_length",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0,200,or_greater",
		})

	return property_list


func _ready() -> void:
	if _type == SteeringBehaviorType.OBSTACLE_AVOIDANCE:
		_rectangle_shape2d = RectangleShape2D.new();
		_collision_shape2d = CollisionShape2D.new();
		_collision_shape2d.shape = _rectangle_shape2d;
		_area2d = Area2D.new();
		_area2d.area_entered.connect(_obstacle_entered);
		_area2d.area_exited.connect(_obstacle_exited);
		
		add_child(_area2d);
		_area2d.add_child(_collision_shape2d);


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
		if _type == SteeringBehaviorType.WANDER:
			draw_arc(Vector2.UP * _wander_distance, _wander_radius, 0, 2 * PI, 360, Color(0, 0, 1, 1));
			draw_circle(_wander_target, 5, Color(0, 1, 0, 1));
		
		if _type == SteeringBehaviorType.OBSTACLE_AVOIDANCE:
			var _r = Rect2(Vector2(-_vehicle.width, _vehicle.height / 2 - _vehicle.height / 6), Vector2(_vehicle.width * 2, -_detection_box_length));
			draw_rect(_r, Color.FUCHSIA, false, 1, false);


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

		SteeringBehaviorType.OBSTACLE_AVOIDANCE:
			return _obstacle_avoidance();

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


func _obstacle_avoidance() -> Vector2:
	_detection_box_length = _min_detection_box_length + (_vehicle.velocity.length() / _vehicle.max_speed) * _min_detection_box_length;
	_rectangle_shape2d.size = Vector2(_vehicle.width * 2, _detection_box_length);
	_area2d.position = Vector2(0, -_detection_box_length / 2 + _vehicle.height / 2 - _vehicle.height / 6);
	
	var _dist_to_closest_ip = INF;
	var _closest_obstacle: Obstacle = null;
	var _local_position_obstacle: Vector2;
	
	for o in _obstacles:
		#var _local_position = _vehicle.to_local(o.global_position);
		var _local_position = o.global_position - _vehicle.global_position;
		
		if _local_position.x >= 0:
			var _expanded_radius = o.radius + _vehicle.width;
			
			if abs(_local_position.y) < _expanded_radius:
				var _cx = _local_position.x;
				var _cy = _local_position.y;
				var _sqrt = sqrt(_expanded_radius * _expanded_radius - _cy * _cy);
				
				var _ip = _cx - _sqrt;
				if _ip <= 0:
					_ip = _cx + _sqrt;
					
				if _ip < _dist_to_closest_ip:
					_dist_to_closest_ip = _ip;
					_closest_obstacle = o;
					_local_position_obstacle = _local_position;
	
	if _closest_obstacle:
		var _steering_force = Vector2.ZERO;
		var multiplier = 1.0 + (_detection_box_length - _local_position_obstacle.x) / _detection_box_length;
		_steering_force.y = (_closest_obstacle.radius - _local_position_obstacle.y) * multiplier;
		
		var _breaking_weight = .2;
		_steering_force.x = (_closest_obstacle.radius - _local_position_obstacle.x) * _breaking_weight;
		
		return _vehicle.to_global(_steering_force);
	
	return Vector2.ZERO;


func _obstacle_entered(area: Area2D):
	if area.get_parent() is Obstacle:
		_obstacles.append(area.get_parent());


func _obstacle_exited(area: Area2D):
	if area.get_parent() is Obstacle:
		_obstacles.remove_at(_obstacles.find(area.get_parent()));
