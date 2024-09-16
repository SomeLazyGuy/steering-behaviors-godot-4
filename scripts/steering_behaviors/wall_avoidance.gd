class_name WallAvoidance
extends SteeringBehavior

@export var feeler_length: float:
	set(value):
		feeler_length = value
		_calculate_feelers()
		queue_redraw()
@export var show_feelers: bool

@onready var _vehicle = get_parent()

var _feeler_foreward: RayCast2D = RayCast2D.new()
var _feeler_right: RayCast2D = RayCast2D.new()
var _feeler_left: RayCast2D = RayCast2D.new()

func _ready() -> void:
	_calculate_feelers()
	
	_feeler_foreward.collision_mask = 0b0100
	add_child(_feeler_foreward)
	
	_feeler_right.collision_mask = 0b0100
	add_child(_feeler_right)
	
	_feeler_left.collision_mask = 0b0100
	add_child(_feeler_left)


func _draw() -> void:
	if show_feelers:
		draw_line(Vector2.ZERO, _feeler_foreward.target_position, Color.FUCHSIA)
		draw_line(Vector2.ZERO, _feeler_right.target_position, Color.FUCHSIA)
		draw_line(Vector2.ZERO, _feeler_left.target_position, Color.FUCHSIA)


func calculate() -> Vector2:
	var _closest_feeler: RayCast2D = null
	var _closest_distance: float = INF
	
	if _feeler_foreward.is_colliding():
		var _collision_point = _feeler_foreward.get_collision_point()
		var _distance = (_collision_point - _vehicle.global_position).length()
		if _distance < _closest_distance:
			_closest_feeler = _feeler_foreward
			_closest_distance = _distance
			
	if _feeler_right.is_colliding():
		var _collision_point = _feeler_right.get_collision_point()
		var _distance = (_collision_point - _vehicle.global_position).length()
		if _distance < _closest_distance:
			_closest_feeler = _feeler_right
			_closest_distance = _distance
			
	if _feeler_left.is_colliding():
		var _collision_point = _feeler_left.get_collision_point()
		var _distance = (_collision_point - _vehicle.global_position).length()
		if _distance < _closest_distance:
			_closest_feeler = _feeler_left
			_closest_distance = _distance
	
	if _closest_distance < INF:
		var _collision_depth = (_closest_feeler.target_position - _vehicle.to_local(_closest_feeler.get_collision_point())).length()
		var _steering_force = _closest_feeler.get_collision_normal() * _collision_depth
		return _steering_force
	
	return Vector2.ZERO


func _calculate_feelers() -> void:
	_feeler_foreward.target_position = Vector2.UP * feeler_length
	_feeler_right.target_position = Vector2.RIGHT.rotated(-120) * feeler_length / 2
	_feeler_left.target_position = Vector2.LEFT.rotated(120) * feeler_length / 2
