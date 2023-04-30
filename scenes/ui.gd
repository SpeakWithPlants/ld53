extends Control

const decay_rate = 5.0

var state = "start_screen"
var counting = false
var total_score = 0
var personal_best_score = 0
var elapsed = 0

@onready var total_score_label = $total_score_label
@onready var end_screen = $end_screen
@onready var end_score_label = $end_screen/vbox/end_score
@onready var best_score_label = $end_screen/vbox/hbox/best_score
@onready var anim = $anim


func _ready():
	end_screen.visible = false
	anim.connect("animation_finished", _on_animation_finished)
	pass


func _process(delta):
	if counting:
		elapsed += delta
		if elapsed > (1.0 / decay_rate):
			add_score(-1)
			elapsed = 0
	total_score_label.text = "%d" % total_score
	pass


func add_score(score):
	total_score = max(0, total_score + score)
	pass


func stop():
	counting = false
	elapsed = 0
	end_score_label.text = "%d" % total_score
	personal_best_score = max(personal_best_score, total_score)
	best_score_label.text = "%d" % personal_best_score
	anim.play("show_end_ui")
	end_screen.visible = true
	pass


func reset():
	total_score = 0
	pass


func _on_obstacle_collision(player, obstacle):
	if obstacle.has_method("_on_collision"):
		obstacle._on_collision(player)
	pass


func _on_animation_finished(anim_name):
	if anim_name == "hide_ui":
		state = "playing"
	elif anim_name == "show_end_ui":
		state = "replay_screen"
	pass


