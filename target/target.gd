extends Node2D;
class_name Target;

@export var radius: float;
@export var color: Color;

func _draw() -> void:
	draw_circle(Vector2(0, 0), radius, color);


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == 1:
		set_position(get_viewport().get_mouse_position());
