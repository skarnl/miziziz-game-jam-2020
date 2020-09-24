extends RigidBody2D

signal possessed
signal died
signal searching
signal stop_searching
signal alerted
signal stop_alerted
signal player_hit

var velocity: Vector2 = Vector2.ZERO
var MAX_SPEED = 110
enum DIRECTIONS { right, down, left, up }

var player_nearby = false

enum { NORMAL, POSSESSED, WAS_POSSESSED, SEARCHING, ALERTED }
var current_state = NORMAL

var valid_state_changed = {
	NORMAL: [POSSESSED, SEARCHING],
	POSSESSED: [WAS_POSSESSED],
	WAS_POSSESSED: [POSSESSED],
	SEARCHING: [NORMAL, ALERTED, POSSESSED],
	ALERTED: [SEARCHING]
}


var previous_input
var playerRef

var bounces = 2

var last_known_position


func _ready():
	$hint.hide()

	set_process_unhandled_input(false)
	
	var allPlayers = get_tree().get_nodes_in_group('player')
	playerRef = allPlayers.front()
	
	init_player_detection()


func init_player_detection():
	$PlayerInteractionArea2D.connect('body_entered', self, '_on_Player_nearby')
	$PlayerInteractionArea2D.connect('body_exited', self, '_on_Player_away')
	
	$PlayerDetectionArea2D.connect('body_entered', self, '_on_Player_detected')
	$DetectionTimer.connect('timeout', self, '_on_DetectionTimer_timeout')


var laser_color = Color(1.0, .329, .298)

func _draw():
	if last_known_position and OS.is_debug_build():
		draw_circle((last_known_position - position), 3, laser_color)
		draw_line(Vector2(), (last_known_position - position), laser_color)


func change_state_to(next_state):
	
	print('change_state_to: ', next_state)
	
	if !can_change_state(next_state):
		return
	
	# handle previous state
	match(current_state):
		SEARCHING:
			emit_signal('stop_searching')
				
		ALERTED:
			$PlayerHitArea2D.disconnect('body_entered', self, '_on_Player_hit')
			emit_signal('stop_alerted')
	
	handle_state_change(next_state)

func can_change_state(next_state):
	return next_state in valid_state_changed[current_state]

func handle_state_change(next_state):
	current_state = next_state
	
	match(current_state):
		NORMAL:
			$DetectionTimer.stop()
			
		POSSESSED:
			$AnimationPlayer.play('possessed')
			disconnect('body_entered', self, '_on_body_entered')
			set_deferred('mode', RigidBody2D.MODE_CHARACTER)
			
#			set_process(true)
			set_process_unhandled_input(true)
			
		
		WAS_POSSESSED:
			set_deferred('mode', RigidBody2D.MODE_RIGID)
		
			yield(get_tree(), 'idle_frame')
			
			var torque = 100 if previous_input.x > 0 else -100
			apply_torque_impulse(torque)
			
			apply_impulse(Vector2.ZERO, previous_input * 10)
			
			$screamAudioPlayer.play()
			
#			set_process(false)
			set_process_unhandled_input(false)
			
			call_deferred('set_body_entered_listener')
		
		SEARCHING:
			start_detection_countdown()
			disconnect('body_entered', self, '_on_body_entered')
			set_deferred('mode', RigidBody2D.MODE_CHARACTER)
		
		ALERTED:
			emit_signal('alerted')
			set_deferred('mode', RigidBody2D.MODE_CHARACTER)
			
			$PlayerHitArea2D.connect('body_entered', self, '_on_Player_hit')

func set_body_entered_listener():
	connect('body_entered', self, '_on_body_entered')

func _on_Player_nearby(body):
	if body.is_in_group('player') and current_state in [NORMAL, SEARCHING, WAS_POSSESSED]:
		$hint.show()
		player_nearby = true
		set_process_unhandled_input(true)
		

func _on_Player_away(body):
	if body.is_in_group('player'):
		$hint.hide()
		player_nearby = false
		set_process_unhandled_input(false)

func _on_Player_detected(body):
	if body.is_in_group('player') and current_state in [NORMAL]:
		change_state_to(SEARCHING)

func _on_Player_hit(body):
	if body.is_in_group('player') and current_state in [ALERTED]:
		emit_signal('player_hit')

func start_detection_countdown():
	emit_signal('searching')
	$DetectionTimer.start()
	
func _on_DetectionTimer_timeout():
	var result = look_around()
	
	if result:
		change_state_to(ALERTED)
	else:
		change_state_to(NORMAL)

func look_around():
	if position.distance_to(playerRef.position) > 100:
		return
		
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, playerRef.position, [self])
	
	if result and result.collider.name == 'Ghost':
		last_known_position = result.position
		return true
	
	return false

func _unhandled_input(event):
	if player_nearby and event is InputEventKey:
		if event.is_action_pressed('possess') and current_state != POSSESSED:
			emit_signal('possessed')


func stop_possessing():
	change_state_to(WAS_POSSESSED)

func start_possessing():
	change_state_to(POSSESSED)
	$AnimationPlayer.play('possessed')
	
	$hint.hide()

func _integrate_forces(state):
	if current_state == POSSESSED:
		
		var xform = state.get_transform().rotated(0)
		state.set_transform(xform)
		
		var input_vector = Vector2.ZERO
		
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		input_vector = input_vector.normalized()
		
			
		if input_vector != Vector2.ZERO:
			velocity = input_vector * MAX_SPEED		
		else:
			velocity = Vector2.ZERO
		
		previous_input = input_vector
		
		state.set_linear_velocity(velocity)
	elif current_state == ALERTED:
		look_around()
		update()
		
		if last_known_position.distance_to(self.global_position) > 0.5:
			var motion = (last_known_position - self.global_position)
			state.set_linear_velocity(motion.normalized() * 30)
		else:
			state.set_linear_velocity(Vector2.ZERO)
			change_state_to(SEARCHING)

func _on_body_entered(otherBody):
	if current_state != WAS_POSSESSED:
		return
			
	if otherBody.name == 'walls' or otherBody.name == 'doors':
		play_bounce_sound()
		
		bounces -= 1
		if bounces < 0:
			explode(otherBody)
	
	# TODO check the velocity of me - if it was fast enough, then we will explode
	elif otherBody.is_in_group('enemies'):
		otherBody.explode()
		explode()

func play_bounce_sound():
	randomize()
	var sounds = ['bounceAudioPlayer', 'bounceAudioPlayer2', 'bounceAudioPlayer3']
	sounds.shuffle()
	
	var soundPlayer = sounds.front()
	get_node(soundPlayer).play()

func explode(cause = null):
	emit_signal('died', cause, position)
	
	queue_free()
