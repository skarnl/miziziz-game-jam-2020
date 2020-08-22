extends Node2D

var lightPrefab = preload('res://entities/world/light.tscn')
var enemyLightPrefab = preload('res://entities/world/enemy_light.tscn')
var bloodLightPrefab = preload('res://entities/world/blood_light.tscn')
	
var lightmap = {}
	
func _addLightToTarget(target, prefab):
	if lightmap.has(target.get_instance_id()):
		return
	
	var light = prefab.instance()
	light.set_target(target)
	add_child(light)
	
	lightmap[target.get_instance_id()] = light

func addLight(entity, type):
	match type:
		'enemy':
			_addLightToTarget(entity, enemyLightPrefab)
		'blood':
			_addLightToTarget(entity, bloodLightPrefab)

func removeLightForEnemyInstanceId(enemyInstanceId):
	var child = lightmap[enemyInstanceId]
	child.queue_free()
	
	lightmap.erase(enemyInstanceId)
