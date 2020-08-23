extends Node2D

var possessed = false

var explosionScene = preload('res://entities/world/explosion.tscn')

enum { GHOST, POSSESSED }
var current_state = GHOST

var possessedEnemy
onready var ghost = $Ghost

func _ready():
	AlertManager.reset()
	LightManager.reset()
	$guard_doors.hide()
	
	$MakeDark.show()
	
	var enemies = get_tree().get_nodes_in_group('enemies')
		
	for enemy in enemies:
		enemy.connect('possessed', self, '_on_Enemy_possessed', [enemy])
		enemy.connect('died', self, '_on_Enemy_died', [enemy.get_instance_id()])
		enemy.connect('searching', self, '_on_Enemy_start_searching', [enemy])
		enemy.connect('stop_searching', self, '_on_Enemy_stop_searching', [enemy])
		enemy.connect('alerted', self, '_on_Enemy_alerted', [enemy])
		
func change_state_to(new_state):
	match(current_state):
		GHOST:
			if new_state in [POSSESSED]:
				handle_state_change(new_state)
				
		POSSESSED:
			if new_state in [GHOST]:
				handle_state_change(new_state)
			

func handle_state_change(new_state):
	current_state = new_state
	
	match(current_state):
		GHOST:
			$walls.set_collision_bounce(0.9)
			$guard_doors.hide()
			$ghost_doors.show()
#
		POSSESSED:
			$walls.set_collision_bounce(0)
			$guard_doors.show()
			$ghost_doors.hide()
#			
		
func _on_Enemy_possessed(enemy):
	if current_state == POSSESSED:
		set_process(false)
		ghost.possess_end()
		
		possessedEnemy.explode()
		
	start_possessing(enemy)
	
	
func _on_Enemy_died(cause, enemy_position, enemyInstanceId):
	
	#if cause and cause.name == 'walls':
	var explosion = explosionScene.instance()
	explosion.position = enemy_position
	$explosions_instances.add_child(explosion)
	Audioplayer.play('splash')
	
	LightManager.removeForEnemyInstanceId(enemyInstanceId)
	
	LightManager.addLightToTarget(explosion, 'blood')

func _on_Enemy_start_searching(enemy):
	AlertManager.addMarkToTarget(enemy, 'question')

func _on_Enemy_stop_searching(enemy):
	AlertManager.removeForEnemyInstanceId(enemy.get_instance_id())
	
func _on_Enemy_alerted(enemy):
	AlertManager.addMarkToTarget(enemy, 'alert')

func _on_Player_hit():
	game_over()
	pass

func _process(delta):
	if current_state == POSSESSED:
		$Ghost.position = possessedEnemy.position
	

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed('possess') and current_state == POSSESSED:
			stop_possessing()

				
func start_possessing(enemy):
	ghost.possess_start(enemy.position)
	LightManager.addLightToTarget(enemy, 'enemy')
	
	yield(get_tree().create_timer(0.3), 'timeout')
	
	possessedEnemy = enemy
	enemy.start_possessing()
	change_state_to(POSSESSED)
	set_process(true)


func stop_possessing():
	set_process(false)
	change_state_to(GHOST)

	possessedEnemy.stop_possessing()
	
	ghost.position = possessedEnemy.position
	possessedEnemy = null
	ghost.possess_end()

	
func game_over():
	Game.game_over()
