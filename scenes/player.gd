extends CharacterBody2D
class_name Player

signal deliver(player)

const max_speed = 850.0
const gravity = 800.0
const friction = 100.0
const control = 500.0
const turn_speed = 4.5

var use_mouse = false
var direction = Vector2.RIGHT

@onready var sprite = $sprite
@onready var trail = $sprite/trail
@onready var shred = $sprite/shred
@onready var speed_label = $speed_label

func _ready():
	trail.emitting = false
	shred.emitting = false
	pass


func _process(_delta):
	_update_visual()
	pass


func _physics_process(delta):
	_get_delivery_input()
	_update_direction(delta)
	_update_velocity(delta)
	move_and_slide()
	pass


func _update_visual():
	sprite.rotation = direction.angle()
	speed_label.text = "%0.1f" % velocity.length()
	_update_trail()


func _update_direction(delta):
	var target_direction = get_target_direction()
	if target_direction == Vector2.ZERO:
		target_direction = direction
	if use_mouse:
		direction = target_direction
		return
	if target_direction == Vector2.ZERO:
		return
	var angle_diff = direction.angle_to(target_direction)
	var frame_rotation = sign(angle_diff) * turn_speed * delta
	if abs(angle_diff) < (turn_speed * delta):
		frame_rotation = angle_diff
	direction = direction.rotated(frame_rotation)
	pass


func _update_velocity(delta):
	var downhill_dot = direction.dot(Vector2.DOWN)
	var downhill_multiplier = sign(downhill_dot) * sqrt(abs(downhill_dot))
	var friction_multiplier = 1.0 - max(0.0, downhill_dot)
	var max_speed_multiplier = (downhill_dot + 1.0) / 2.0
	var speed = velocity.length()
	var current_max_speed = max_speed * max_speed_multiplier
	speed += gravity * downhill_multiplier * delta
	speed = move_toward(speed, 0, friction_multiplier * friction * delta)
	speed = clamp(speed, -current_max_speed, current_max_speed)
	velocity = velocity.move_toward(direction * speed, control * delta)
	pass


func _update_trail():
	var speed = velocity.length()
	if speed > 0:
		var ui = get_tree().get_first_node_in_group("ui")
		ui.counting = true
	trail.emitting = speed > 0
	shred.emitting = abs(velocity.normalized().dot(direction)) < 0.8 and trail.emitting
	pass


func _get_delivery_input():
	if Input.is_action_just_pressed("mouse_right"):
		emit_signal("deliver", self)
	pass


func get_target_direction():
	var new_target_direction = Vector2.ZERO
	if Input.is_action_pressed("mouse_left"):
		use_mouse = true
		var mouse_pos = get_global_mouse_position()
		var angle_to_mouse = global_position.angle_to_point(mouse_pos)
		new_target_direction = Vector2.RIGHT.rotated(angle_to_mouse)
	return new_target_direction.normalized()
