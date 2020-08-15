extends Node2D

var velocity: Vector2 = Vector2.ZERO
var MAX_SPEED = 3
	
func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
		
	if input_vector != Vector2.ZERO:
		velocity = input_vector * MAX_SPEED		
	else:
		velocity = Vector2.ZERO
	
	position.x = clamp(position.x + velocity.x, 0, 512)
	position.y = clamp(position.y + velocity.y, 0, 300)
