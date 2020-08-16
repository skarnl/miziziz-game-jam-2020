extends Node2D

var possessed = false

var possessedEnemy
onready var ghost = $Ghost

func _ready():
	var enemies = get_tree().get_nodes_in_group('enemies')
		
	for enemy in enemies:
		enemy.connect('possessed', self, '_on_Enemy_possessed', [enemy])
		enemy.connect('hit', self, '_on_Enemy_hit', [enemy])
		
		
func _on_Enemy_possessed(enemy):
	start_possessing(enemy)
	
	
func _on_Enemy_hit(enemy):
	pass
	

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed('exit_possess') and possessed:
			stop_possessing()

				
func start_possessing(enemy):
	ghost.possess_start(enemy.position)
	possessedEnemy = enemy
	enemy.possessed = true
	possessed = true


func stop_possessing():
	possessed = false
	possessedEnemy.possessed = false
	ghost.position = possessedEnemy.position
	possessedEnemy = null
	ghost.possess_end()
	
