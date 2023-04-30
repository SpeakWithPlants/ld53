extends Area2D

var points = [
	Vector2.ZERO,
	Vector2.RIGHT,
	Vector2.ONE,
	Vector2.DOWN,
]

@onready var collider = $collider


func _ready():
	_update_polygon()
	pass


func set_corners(p1, p2):
	var min_x = min(p1.x, p2.x)
	var max_x = max(p1.x, p2.x)
	var min_y = min(p1.y, p2.y)
	var max_y = max(p1.y, p2.y)
	var new_points = []
	new_points.append(Vector2(min_x, min_y))
	new_points.append(Vector2(max_x, min_y))
	new_points.append(Vector2(max_x, max_y))
	new_points.append(Vector2(min_x, max_y))
	points = new_points
	if collider != null:
		_update_polygon()
	pass


func _update_polygon():
	collider.polygon = points
	pass
