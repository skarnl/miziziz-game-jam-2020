extends Sprite

var target

func set_target(_target):
	target = _target

func _process(delta):
	if !target:
		return
		
	position = target.position - Vector2(0, 20)
