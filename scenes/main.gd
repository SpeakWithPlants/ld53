extends Node2D

const player_scn = preload("res://scenes/player.tscn")
const level_scn = preload("res://scenes/level.tscn")

var player
var level

@onready var camera = $camera
@onready var ui = $camera/ui


func _ready():
	pass


func _process(_delta):
	camera.global_position = Vector2.DOWN * 1000
	if player != null:
		camera.global_position = player.global_position
	pass


func _physics_process(_delta):
	if Input.is_action_just_pressed("mouse_left") or Input.is_action_just_pressed("mouse_right"):
		if ui != null and (ui.state == "start_screen" or ui.state == "replay_screen"):
			start()
			ui.reset()
			ui.anim.play("hide_ui")
			await ui.anim.animation_finished
			player.halted = false
			pass
	pass


func start():
	player = player_scn.instantiate()
	add_child(player)
	if level != null:
		level.queue_free()
	level = level_scn.instantiate()
	add_child(level)
	await level.generate_level(10, 3.0)
	level.endzone.connect("body_entered", _on_body_entered_endzone)
	pass


func _on_body_entered_endzone(body):
	if body is Player:
		# do finish here
		ui.counting = false
		body.halted = true
		await get_tree().create_timer(1).timeout
		ui.stop()
		pass
	pass

