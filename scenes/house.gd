extends StaticBody2D

const delivery_ping_scn = preload("res://scenes/delivery_ping.tscn")
const collision_penalty = 50

var ui

@onready var delivery_area = $delivery_area
@onready var delivery_area_collider = $delivery_area/collider


func _ready():
	ui = get_tree().get_first_node_in_group("ui")
	delivery_area.connect("body_entered", _on_delivery_area_body_entered)
	delivery_area.connect("body_exited", _on_delivery_area_body_exited)
	pass


func _on_delivery(player):
	delivery_area_collider.disabled = true
	var dist = global_position.distance_to(player.global_position)
	var dist_prop = dist / delivery_area_collider.shape.radius
	var new_ping = delivery_ping_scn.instantiate()
	var point_value = new_ping.max_point_value * (1.0 - dist_prop) + new_ping.bonus_point_value
	new_ping.point_value = point_value
	add_child(new_ping)
	new_ping.global_position = player.global_position
	ui.add_score(point_value)
	pass


func _on_collision(_player):
	var new_ping = delivery_ping_scn.instantiate()
	new_ping.point_value = -collision_penalty
	add_child(new_ping)
	new_ping.global_position = global_position
	ui.add_score(-collision_penalty)
	pass


func _on_delivery_area_body_entered(body):
	if body is Player:
		body.deliver.connect(_on_delivery)
	pass


func _on_delivery_area_body_exited(body):
	if body is Player:
		body.deliver.disconnect(_on_delivery)
	pass
