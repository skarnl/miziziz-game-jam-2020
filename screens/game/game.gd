extends Node2D

var possessed = false

var possessedEnemy
onready var ghost = $Ghost

func _ready():
	var enemies = get_tree().get_nodes_in_group('enemies')
		
	for enemy in enemies:
		enemy.connect('clicked', self, '_on_Enemy_clicked', [enemy])
		
func _on_Enemy_clicked(enemy):
	# TODO move ghost into target
	
	print("enemy clicked")
	
	ghost.possess_start()
	
	# TODO check if there is already someone possessed
	# TODO this isn't possible, you can only possess when you are ghost
	
	possessedEnemy = enemy
	enemy.possessed = true
	possessed = true
