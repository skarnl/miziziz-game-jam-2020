extends KinematicBody2D

signal possessed
signal hit
signal hit_player

var possessed = false setget set_possessed
var velocity: Vector2 = Vector2.ZERO
var MAX_SPEED = 70
enum DIRECTIONS { right, down, left, up }
var look_directions = {
	DIRECTIONS.right: 0,
	DIRECTIONS.down: 90,
	DIRECTIONS.left: 180,
	DIRECTIONS.up: 270,
}
var player_nearby = false
export(DIRECTIONS) var current_look_direction =  DIRECTIONS.right

enum { POSSESSED, NORMAL, ALERTED, SEARCHING, DEAD }
var current_state = NORMAL

var playerRef


func _ready():
	$hint.hide()
	
	set_process(false)
	set_process_unhandled_input(false)
	
	set_look_direction()
	set_player_detection()

	var allPlayers = get_tree().get_nodes_in_group('player')
	playerRef = allPlayers.front()

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


func set_look_direction():
	$Rotation.rotation_degrees = look_directions[current_look_direction]


func set_player_detection():
	$Rotation/PlayerInteractionArea2D.connect('body_entered', self, '_on_Player_nearby')
	$Rotation/PlayerInteractionArea2D.connect('body_exited', self, '_on_Player_away')
	
	$Rotation/PlayerDetectionArea2D.connect('body_entered', self, '_on_Player_detected')
	
	$Rotation/PlayerHitArea2D.connect('body_entered', self, '_on_Player_hit')
	
	
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
	

func _on_Player_detected(body):
	if body.is_in_group('player') and current_state == NORMAL:
		change_state_to(ALERTED)
			

func _on_Player_hit(body):
	if body.is_in_group('player') and current_state == ALERTED:
		emit_signal('hit_player')
		

func _unhandled_input(event):
	if player_nearby and event is InputEventKey:
		if event.is_action_pressed('attack'):
			emit_signal('hit')
		elif event.is_action_pressed('possess') and not possessed:
			emit_signal('possessed')


func set_possessed(new_value):
	possessed = new_value
	$AnimationPlayer.play('possessed')
	
	set_process(possessed)
	
	current_state = POSSESSED if possessed else NORMAL
	
	$Rotation/PlayerInteractionArea2D/CollisionShape2D.disabled = possessed
	
	if possessed:
		$hint.hide()
		$Rotation/VisionCone.hide()
	else:
		$Rotation/VisionCone.show()


func _process(delta):
	if current_state == POSSESSED:
		var input_vector = Vector2.ZERO
		
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		input_vector = input_vector.normalized()
			
		if input_vector != Vector2.ZERO:
			velocity = input_vector * MAX_SPEED		
		else:
			velocity = Vector2.ZERO
		
		move_and_slide(velocity)
	
	elif current_state == ALERTED:
		var motion = (playerRef.get_global_position() - self.global_position)
		move_and_slide(motion.normalized() * 10)
		
		$Rotation.look_at(playerRef.position)
