class_name ObjectManager
extends Node2D

var map = {}

func _addToTarget(target, prefab):
	if map.has(target.get_instance_id()):
		return
	
	var prefabInstance = prefab.instance()
	prefabInstance.set_target(target)
	add_child(prefabInstance)
	
	map[target.get_instance_id()] = prefabInstance

func removeForEnemyInstanceId(enemyInstanceId):
	if !map.has(enemyInstanceId):
		return 
		
	var child = map[enemyInstanceId]
	child.queue_free()
	
	map.erase(enemyInstanceId)

func reset():
	for child in get_children():
		child.queue_free()
	
	map.clear()
