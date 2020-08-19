extends Node2D

var possessed = false

var explosionScene = preload('res://entities/world/explosion.tscn')

enum { GHOST, POSSESSED, AIMING }
var current_state = GHOST

var possessedEnemy
onready var ghost = $Ghost

func _ready():
	var enemies = get_tree().get_nodes_in_group('enemies')
		
	for enemy in enemies:
		enemy.connect('possessed', self, '_on_Enemy_possessed', [enemy])
		enemy.connect('died', self, '_on_Enemy_died', [enemy])
		
		
func change_state_to(new_state):
	match(current_state):
		GHOST:
			if new_state in [POSSESSED]:
				handle_state_change(new_state)
				
		POSSESSED:
			if new_state in [AIMING, GHOST]:
				handle_state_change(new_state)
			
		AIMING:
			if new_state == GHOST:
				handle_state_change(new_state)


func handle_state_change(new_state):
	current_state = new_state

		
func _on_Enemy_possessed(enemy):
	start_possessing(enemy)
	
	
func _on_Enemy_died(enemy):
	var explosion = explosionScene.instance()
	explosion.position = enemy.position
	$explosions_instances.add_child(explosion)
	
func _on_Player_hit():
	game_over()
	pass

func _process(delta):
	if current_state == POSSESSED:
		$Ghost.position = possessedEnemy.position
	

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed('exit_possess') and current_state == POSSESSED:
			stop_possessing()

				
func start_possessing(enemy):
	ghost.possess_start(enemy.position)
	
	yield(get_tree().create_timer(0.3), 'timeout')
	
	possessedEnemy = enemy
	enemy.possessed = true
	change_state_to(POSSESSED)
	set_process(true)


func stop_possessing():
	set_process(false)
	change_state_to(GHOST)
	finish_aiming()
	
	
func finish_aiming():
	possessedEnemy.possessed = false
	ghost.position = possessedEnemy.position
	possessedEnemy = null
	ghost.possess_end()
	
	
	
func game_over():
	Game.game_over()
