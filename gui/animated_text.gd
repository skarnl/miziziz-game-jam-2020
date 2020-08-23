extends Label

func _ready():
	percent_visible = 0
	$Area2D.connect('body_entered', self, '_play_animation')
	
func _play_animation(body):
	if body.name == 'Ghost' or body.name == 'Human2':
		$Area2D.disconnect('body_entered', self, '_play_animation')
		$AnimationPlayer.play('show')
