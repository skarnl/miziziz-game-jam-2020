extends KinematicBody2D

signal possessed
signal hit

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

enum STATES { POSSESSED, NORMAL, ALERTED, DEAD }
var current_state = STATES.NORMAL


func _ready():
	$hint.hide()
	
	set_process(false)
	set_process_unhandled_input(false)
	
	set_look_direction()
	set_player_detection()


func set_look_direction():
	$Rotation.rotation_degrees = look_directions[current_look_direction]


func set_player_detection():
	$PlayerInteractionArea2D.connect('body_entered', self, '_on_Player_nearby')
	$PlayerInteractionArea2D.connect('body_exited', self, '_on_Player_away')
	
	
func _on_Player_nearby(body):
	if body.is_in_group('player'):
		
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
		elif event.is_action_pressed('possess') and not possessed:
			emit_signal('possessed')


func move(towards:Vector2):
	position += towards
	

func set_possessed(new_value):
	possessed = new_value
	$AnimationPlayer.play('possessed')
	
	set_process(possessed)
	
	current_state = STATES.POSSESSED if possessed else STATES.NORMAL
	
	$PlayerInteractionArea2D/CollisionShape2D.disabled = possessed
	
	if possessed:
		$hint.hide()

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
