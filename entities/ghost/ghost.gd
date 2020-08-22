extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var MAX_SPEED = 110
var possessed = false
	
func _ready():
	Audioplayer.play('spawn')
	
	yield($AnimationPlayer, 'animation_finished')
	
	$AnimationPlayer.play('move')
	$possessedAudioPlayer.play()
	
func _process(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * MAX_SPEED
		
		$Sprite.flip_h = velocity.x > 0
		
		if possessed:
			$possessedAudioPlayer.set_volume_db(0)
	else:
		velocity = Vector2.ZERO
		$possessedAudioPlayer.set_volume_db(-80)
	
	move_and_slide(velocity)
	
	
func possess_start(targetPosition):
	$Tween.interpolate_property(self, 'position', position, targetPosition, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
	$CollisionShape2D.disabled = true
	
	Audioplayer.play('possess')
	
	yield($Tween, 'tween_completed')
	
	hide()
	
	possessed = true

func possess_end():
	possessed = false
	
	$CollisionShape2D.disabled = false
	
	Audioplayer.play('exit_possess')
	show()
	set_process(false)
	
	yield(get_tree().create_timer(0.4), 'timeout')
	
	set_process(true)
