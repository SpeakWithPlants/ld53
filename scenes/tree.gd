extends StaticBody2D

const delivery_ping_scn = preload("res://scenes/delivery_ping.tscn")
const collision_penalty = 20

var ui

func _ready():
	ui = get_tree().get_first_node_in_group("ui")
	pass


func _on_collision(_player):
	var new_ping = delivery_ping_scn.instantiate()
	new_ping.point_value = -collision_penalty
	add_child(new_ping)
	new_ping.global_position = global_position
	ui.add_score(-collision_penalty)
	pass
