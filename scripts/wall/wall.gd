class_name Wall
extends Node2D

var _rect: Rect2

func _ready() -> void:
	_rect = $StaticBody2D/CollisionShape2D.shape.get_rect()
	queue_redraw()


func _draw() -> void:
	draw_rect(_rect, Color.BLACK)
