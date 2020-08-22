extends RigidBody2D

signal possessed
signal died
signal searching
signal stop_searching
signal alerted

var velocity: Vector2 = Vector2.ZERO
var MAX_SPEED = 110
enum DIRECTIONS { right, down, left, up }

var player_nearby = false

enum { NORMAL, POSSESSED, WAS_POSSESSED, SEARCHING, ALERTED }
var current_state = NORMAL

var previous_input
var playerRef

var bounces = 0

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


func _physics_process(delta):
	aim()
	update()

var laser_color = Color(1.0, .329, .298)

func _draw():
	if hit_pos:
		draw_circle((hit_pos - position), 4, laser_color)
		draw_line(Vector2(), (hit_pos - position), laser_color)


func change_state_to(next_state):
	
	print('change_state_to: ', next_state)
	
	match(current_state):
		NORMAL:
			if next_state in [POSSESSED, SEARCHING]:
				handle_state_change(next_state)
			
		POSSESSED:
			if next_state in [WAS_POSSESSED]:
				handle_state_change(next_state)

		WAS_POSSESSED:
			if next_state in [POSSESSED]:
				handle_state_change(next_state)
		
		SEARCHING:
			if next_state in [NORMAL, ALERTED, POSSESSED]:
				emit_signal('stop_searching')
				handle_state_change(next_state)
				
	
func handle_state_change(next_state):
	current_state = next_state
	
	match(current_state):
		NORMAL:
			$DetectionTimer.stop()
			
		POSSESSED:
			$AnimationPlayer.play('possessed')
			set_mode(RigidBody2D.MODE_CHARACTER)
			
#			set_process(true)
			set_process_unhandled_input(true)
			
			disconnect('body_entered', self, '_on_body_entered')
		
		WAS_POSSESSED:
			set_mode(RigidBody2D.MODE_RIGID)
		
			yield(get_tree(), 'idle_frame')
			
			var torque = 100 if previous_input.x > 0 else -100
			apply_torque_impulse(torque)
			
			apply_impulse(Vector2.ZERO, previous_input * 10)
			
#			set_process(false)
			set_process_unhandled_input(false)
			
			connect('body_entered', self, '_on_body_entered')
		
		SEARCHING:
			start_detection()
		
		ALERTED:
			emit_signal('alerted')
			set_mode(RigidBody2D.MODE_CHARACTER)
			
#			set_process(true)
	
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
	if body.is_in_group('player'):
		change_state_to(SEARCHING)

func start_detection():
	emit_signal('searching')
	$DetectionTimer.start()
	
	
var hit_pos

func aim():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, playerRef.position, [self])
	
	if result:
		hit_pos = result.position
		

func _on_DetectionTimer_timeout():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, playerRef.position, [self])
	
	if result and result.collider.name == 'Ghost':
		change_state_to(ALERTED)
	else:
		change_state_to(NORMAL)

func _unhandled_input(event):
	if player_nearby and event is InputEventKey:
		if event.is_action_pressed('attack'):
			emit_signal('hit')
		elif event.is_action_pressed('possess') and current_state != POSSESSED:
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
		var motion = (playerRef.get_global_position() - self.global_position)
		state.set_linear_velocity(motion.normalized() * 30)
		
		# TODO check distance? or line of sight?

func _on_body_entered(otherBody):
	print("_on_body_entered", otherBody.name)
	
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
