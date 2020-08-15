extends Area2D

signal clicked

var possessed = false setget set_possessed
var velocity: Vector2 = Vector2.ZERO
var MAX_SPEED = 3

func _ready():
	set_process(false)
	$Timer.connect('timeout', self, '_on_Timer_timeout')
	
func _on_Timer_timeout():
#	move()
	pass

func move(towards:Vector2):
	position += towards

func _on_Human_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		emit_signal('clicked')

func set_possessed(new_value):
	possessed = new_value
	
	set_process(possessed)

func _process(delta):
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
