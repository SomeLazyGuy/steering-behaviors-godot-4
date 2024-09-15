class_name ObstacleOvoidance
extends SteeringBehavior

@export var min_detection_box_length: float
@export var show_visuals: bool

@onready var _vehicle = get_parent()

var _detection_box_length: float
var _area2d: Area2D
var _collision_shape2d: CollisionShape2D
var _rectangle_shape2d: RectangleShape2D
var _obstacles: Array[Obstacle]

func _ready() -> void:
	_rectangle_shape2d = RectangleShape2D.new();
	_collision_shape2d = CollisionShape2D.new();
	_collision_shape2d.shape = _rectangle_shape2d;
	_area2d = Area2D.new();
	_area2d.area_entered.connect(_obstacle_entered);
	_area2d.area_exited.connect(_obstacle_exited);

	add_child(_area2d);
	_area2d.add_child(_collision_shape2d);


func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if show_visuals:
		var _r = Rect2(Vector2(-_vehicle.width, _vehicle.height / 2 - _vehicle.height / 6), Vector2(_vehicle.width * 2, -_detection_box_length));
		draw_rect(_r, Color.FUCHSIA, false, 1, false);


func calculate() -> Vector2:
	_detection_box_length = min_detection_box_length + (_vehicle.velocity.length() / _vehicle.max_speed) * min_detection_box_length;
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
