extends Area2D

func _ready():
	connect('body_entered', self, '_on_Player_entered')
		
func _on_Player_entered(body):
	if body.name == 'Ghost':
		Game.goto_next_level()

