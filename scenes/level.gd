extends Node2D

const house_space_y_min = 600
const house_space_y_max = 1200
const house_space = 100
const tree_space = 60
const fence_height = 32
const endzone_height = 200
const fence_scn = preload("res://scenes/fence.tscn")
const tree_scn = preload("res://scenes/tree.tscn")
const house_scn = preload("res://scenes/house.tscn")
const endzone_scn = preload("res://scenes/endzone.tscn")

var noise
var course_width
var course_length
var endzone


func _ready():
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	generate_level(10, 2.0)
	pass


func generate_level(houses, tree_density):
	var view_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var view_scale = ProjectSettings.get_setting("display/window/stretch/scale")
	var scaled_width = view_width / view_scale
	course_width = scaled_width * 2.5
	_generate_houses(houses)
	_generate_fences()
	_generate_trees(tree_density)
	_generate_endzone()
	pass


func _generate_houses(houses):
	var last_y = 0
	for i in range(houses):
		var house_y = last_y + randf_range(house_space_y_min, house_space_y_max)
		last_y = house_y
		var house_x_min = course_width / 2.0 - house_space
		var house_x = randf_range(-house_x_min, house_x_min)
		_add_house_at(Vector2(house_x, house_y))
		pass
	course_length = last_y + house_space_y_max
	pass


func _generate_fences():
	var current_height = 0
	while current_height < course_length:
		_add_fence_at(Vector2.LEFT * course_width / 2.0 + Vector2.DOWN * current_height)
		_add_fence_at(Vector2.RIGHT * course_width / 2.0 + Vector2.DOWN * current_height)
		current_height += fence_height
	pass


func _generate_trees(tree_density):
	var x_start = -course_width / 2.0 + tree_space
	var x_end = course_width / 2.0 - tree_space
	for x in range(x_start, x_end, tree_space):
		for y in range(0, course_length - house_space, tree_space * 2.0):
			var noise_at_pos = noise.get_noise_2d(x, y)
			var spawn_chance = noise_at_pos * tree_density
			if randf() < spawn_chance:
				var offset = Vector2.RIGHT.rotated(TAU * randf()) * tree_space / 2.0
				_add_tree_at(Vector2(x, y) + offset)
	pass


func _generate_endzone():
	var new_endzone = endzone_scn.instantiate()
	var top_left = Vector2(-course_width / 2.0, course_length)
	var bottom_right = top_left + Vector2(course_width, endzone_height)
	new_endzone.set_corners(top_left, bottom_right)
	add_child(new_endzone)
	endzone = new_endzone
	pass


func _add_house_at(pos):
	var new_house = house_scn.instantiate()
	new_house.global_position = pos
	add_child(new_house)
	pass


func _add_fence_at(pos):
	var new_fence = fence_scn.instantiate()
	new_fence.global_position = pos
	add_child(new_fence)
	pass


func _add_tree_at(pos):
	for house in get_tree().get_nodes_in_group("houses"):
		if house.global_position.distance_to(pos) < house_space * 1.5:
			return
	var new_tree = tree_scn.instantiate()
	new_tree.global_position = pos
	add_child(new_tree)
	pass
