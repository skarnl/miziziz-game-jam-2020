extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var MAX_SPEED = 90
	
func _ready():
	spawn()
	
func _process(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
		
	if input_vector != Vector2.ZERO:
		velocity = input_vector * MAX_SPEED		
	else:
		velocity = Vector2.ZERO
	
	move_and_slide(velocity)


func spawn():
	Audioplayer.play('spawn')
	
func possess_start(targetPosition):
	$Tween.interpolate_property(self, 'position', position, targetPosition, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
	
	Audioplayer.play('possess')
	
	yield($Tween, 'tween_completed')
	
	hide()

func possess_end():
	Audioplayer.play('possess')
	show()
