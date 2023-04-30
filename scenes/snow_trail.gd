extends Line2D

var point

func _ready():
	pass


func _physics_process(_delta):
	global_position = Vector2.ZERO
	point = get_parent().global_position
	add_point(point)
	if points.size() > 100:
		remove_point(0)
	pass
