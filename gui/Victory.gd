extends Control

func _ready():
	hide()
	$Label2.percent_visible = 0

func show_victory():
	show()
	
	$AnimationPlayer.play('show')
