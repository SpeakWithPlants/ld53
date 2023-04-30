extends Node2D

const max_point_value = 250.0
const bonus_point_value = 50.0

var point_value = max_point_value

@onready var score_label = $text/score_label
@onready var anim = $anim


func _ready():
	score_label.text = "+%d" % point_value
	var outline_color = score_label.get("theme_override_colors/font_outline_color")
	outline_color.r = clamp(1.0 - point_value / max_point_value, 0.0, 1.0)
	score_label.set("theme_override_colors/font_outline_color", outline_color)
	anim.connect("animation_finished", _on_animation_finished)
	anim.play("bounce")
	pass


func _on_animation_finished(anim_name):
	if anim_name == "bounce":
		queue_free()
	pass
