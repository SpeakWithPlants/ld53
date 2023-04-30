extends Control

const decay_rate = 5.0

var counting = false
var total_score = 0
var elapsed = 0

@onready var total_score_label = $total_score_label
@onready var end_score_label = $bg/end_screen/vbox/end_score
@onready var anim = $anim


func _process(delta):
	if counting:
		elapsed += delta
		if elapsed > (1.0 / decay_rate):
			add_score(-1)
			elapsed = 0
	total_score_label.text = "%d" % total_score
	pass


func add_score(score):
	total_score += score
	pass


func stop():
	counting = false
	elapsed = 0
	end_score_label = "%d" % total_score
	anim.play("show_ui")
	pass
