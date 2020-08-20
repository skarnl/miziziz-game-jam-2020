extends RigidBody2D

signal possessed
signal died

var possessed = false setget set_possessed
var velocity: Vector2 = Vector2.ZERO
var MAX_SPEED = 110
enum DIRECTIONS { right, down, left, up }

var player_nearby = false

enum { POSSESSED, NORMAL, ALERTED, SEARCHING, DEAD }
var current_state = NORMAL

var playerRef


func _ready():
	$hint.hide()
	
	set_process_unhandled_input(false)
	
	set_player_detection()

	var allPlayers = get_tree().get_nodes_in_group('player')
	playerRef = allPlayers.front()
	
	connect('body_entered', self, '_on_body_entered')


func _on_body_entered(otherBody):
	print("_on_body_entered")
	
#	if otherBody.is_in_group('enemies'):
#		otherBody.explode()
#		explode()


func explode():
	emit_signal('died')
	
	queue_free()


func change_state_to(next_state):
	match(current_state):
		NORMAL:
			handle_state_change(next_state)
			
		POSSESSED:
			if next_state in [NORMAL, DEAD]:
				handle_state_change(next_state)
			
		ALERTED:
			if next_state in [NORMAL, DEAD]:
				handle_state_change(next_state)
	
	
func handle_state_change(next_state):
	current_state = next_state
	
	match(current_state):	
		NORMAL:
			set_process(false)
			set_process_unhandled_input(false)
			
		ALERTED:
			$AlertAnimationPlayer.play('alert')
			set_process(true)
			
		POSSESSED:
			set_process(true)
			set_process_unhandled_input(true)
			
		DEAD:
			#TODO play dead animation
			
			set_process(false)
			set_process_unhandled_input(false)


func set_player_detection():
	$PlayerInteractionArea2D.connect('body_entered', self, '_on_Player_nearby')
	$PlayerInteractionArea2D.connect('body_exited', self, '_on_Player_away')
	
	
func _on_Player_nearby(body):
	if body.is_in_group('player') and current_state == NORMAL:
		
		$hint.show()
		player_nearby = true
		set_process_unhandled_input(true)
		

func _on_Player_away(body):
	if body.is_in_group('player'):
		
		$hint.hide()
		player_nearby = false
		set_process_unhandled_input(false)
		

func _unhandled_input(event):
	if player_nearby and event is InputEventKey:
		if event.is_action_pressed('attack'):
			emit_signal('hit')
		elif event.is_action_pressed('possess') and current_state != POSSESSED:
			emit_signal('possessed')


func set_possessed(new_value):
	possessed = new_value
	$AnimationPlayer.play('possessed')
	
	if not possessed:
		set_mode(RigidBody2D.MODE_RIGID)
		
		yield(get_tree(), 'idle_frame')
		
		var torque = 100 if previous_input.x > 0 else -100
		apply_torque_impulse(torque)
		
		apply_impulse(Vector2.ZERO, previous_input * 10)
	else:
		set_mode(RigidBody2D.MODE_CHARACTER)
		
	current_state = POSSESSED if possessed else NORMAL
	
	if possessed:
		$hint.hide()


var previous_input

func _integrate_forces(state):
	if current_state == POSSESSED:
		
		var xform = state.get_transform().rotated(0)
		state.set_transform(xform)
		
		var input_vector = Vector2.ZERO
		
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		input_vector = input_vector.normalized()
		
			
		if input_vector != Vector2.ZERO:
			previous_input = input_vector
			velocity = input_vector * MAX_SPEED		
		else:
			velocity = Vector2.ZERO
		
		state.set_linear_velocity(velocity)
