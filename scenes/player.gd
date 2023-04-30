extends CharacterBody2D
class_name Player

signal deliver(player)
signal obstacle_collision(player, obstacle)

const max_speed = 850.0
const gravity = 800.0
const friction = 100.0
const control = 500.0
const turn_speed = 4.5

var use_mouse = false
var direction = Vector2.RIGHT
var halted = true
var recovering = false

@onready var sprite = $sprite
@onready var particles = $particles
@onready var trail = $particles/trail
@onready var shred = $particles/shred
@onready var speed_label = $speed_label
@onready var collider = $collider
@onready var recover_timer = $recover_timer
@onready var trail_source_1 = $trail_point_1
@onready var trail_source_2 = $trail_point_2
@onready var trail_point_1 = $particles/trail_point_1
@onready var trail_point_2 = $particles/trail_point_2

func _ready():
	trail.emitting = false
	shred.emitting = false
	var ui = get_tree().get_first_node_in_group("ui")
	connect("obstacle_collision", ui._on_obstacle_collision)
	pass


func _process(_delta):
	_update_visual()
	pass


func _physics_process(delta):
	_get_delivery_input()
	_update_direction(delta)
	_update_velocity(delta)
	_handle_collisions()
	move_and_slide()
	pass


func _update_visual():
	particles.rotation = direction.angle()
	var desired_frame = max(0, direction.dot(Vector2.DOWN)) * 3
	if direction.dot(Vector2.LEFT) > 0:
		desired_frame += 3
	sprite.frame = int(desired_frame) % 6
	speed_label.text = "%0.1f" % velocity.length()
	_update_trail()


func _update_direction(delta):
	if halted:
		if direction.dot(Vector2.RIGHT) > 0:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
		return
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
	if halted:
		velocity = velocity.move_toward(Vector2.ZERO, friction * 10.0 * delta)
		return
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


func _handle_collisions():
	if velocity.length() > max_speed * 0.2 and recover_timer.is_stopped():
		recovering = false
	if recovering:
		return
	var collisions = get_slide_collision_count()
	if collisions > 0:
		recovering = true
		recover_timer.stop()
		recover_timer.start()
		var obstacle = get_slide_collision(0).get_collider()
		emit_signal("obstacle_collision", self, obstacle)
	pass


func _update_trail():
	var speed = velocity.length()
	if speed > 0:
		var ui = get_tree().get_first_node_in_group("ui")
		ui.counting = true
	trail.emitting = speed > 0
	shred.emitting = abs(velocity.normalized().dot(direction)) < 0.8 and trail.emitting
	trail_source_1.global_position = trail_point_1.global_position
	trail_source_2.global_position = trail_point_2.global_position
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
