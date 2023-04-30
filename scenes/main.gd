extends Node2D

const level_scn = preload("res://scenes/level.tscn")


func _ready():
	var level = level_scn.instantiate()
	add_child(level)
	await level.ready
	level.endzone.connect("body_entered", _on_body_entered_endzone)
	pass


func _on_body_entered_endzone(body):
	if body is Player:
		# do finish here
		pass
	pass

