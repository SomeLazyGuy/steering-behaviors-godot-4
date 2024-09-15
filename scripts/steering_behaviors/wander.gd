class_name Wander
extends SteeringBehavior

@export var wander_radius: float
@export var wander_distance: float
@export var wander_jitter: float
@export var show_visuals: bool

@onready var _vehicle = get_parent()

var wander_target: Vector2

func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if show_visuals:
		draw_arc(Vector2.UP * wander_distance, wander_radius, 0, 2 * PI, 360, Color.BLUE)
		draw_circle(wander_target, 5, Color.GREEN)


func calculate() -> Vector2:
	wander_target += Vector2(randf_range(-1, 1) * wander_jitter, randf_range(-1, 1) * wander_jitter);
	wander_target = wander_target.normalized() * wander_radius;
	wander_target += Vector2.UP * wander_distance;

	return _vehicle.to_global(wander_target) - _vehicle.position;
