extends Node2D
class_name Obstacle

@export var radius: float;

@onready var _area2d: Area2D = Area2D.new();
@onready var _collision_shape2d: CollisionShape2D = CollisionShape2D.new();

func _ready() -> void:
	var _circle_shape2d: CircleShape2D = CircleShape2D.new();
	_circle_shape2d.radius = radius;
	_collision_shape2d.shape = _circle_shape2d;
	
	add_child(_area2d);
	_area2d.add_child(_collision_shape2d);


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color.BLACK);
