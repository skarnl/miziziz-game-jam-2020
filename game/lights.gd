extends Node2D

var lightPrefab = preload('res://entities/world/light.tscn')
var enemyLightPrefab = preload('res://entities/world/enemy_light.tscn')
var bloodLightPrefab = preload('res://entities/world/blood_light.tscn')
	
func _addLightToTarget(target, prefab):
	var light = prefab.instance()
	light.set_target(target)
	add_child(light)

func addLight(entity, type):
	match type:
		'enemy':
			_addLightToTarget(entity, enemyLightPrefab)
		'blood':
			_addLightToTarget(entity, bloodLightPrefab)

func removeLightForEnemy(enemy):
	for child in get_children():
		if child.target.name == enemy.name:
			child.queue_free()
			break
