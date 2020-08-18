extends Node2D

var possessed = false

enum { GHOST, POSSESSED, AIMING }
var current_state = GHOST

var possessedEnemy
onready var ghost = $Ghost

func _ready():
	var enemies = get_tree().get_nodes_in_group('enemies')
		
	for enemy in enemies:
		enemy.connect('possessed', self, '_on_Enemy_possessed', [enemy])
		enemy.connect('hit', self, '_on_Enemy_hit', [enemy])
		enemy.connect('hit_player', self, '_on_Player_hit')
		
		
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
	
	
func _on_Enemy_hit(enemy):
	pass
	
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
