extends Node2D

var questionMarkPrefab = preload('res://gui/QuestionMark.tscn')
var alertMarkPrefab = preload('res://gui/AlertMark.tscn')

var markmap = {}

func addMarkToTarget(target, markType):
	match(markType):
		'question':
			_addMarkToTarget(target, questionMarkPrefab)
		'alert':
			_addMarkToTarget(target, alertMarkPrefab)
	
func _addMarkToTarget(target, prefab):
	if markmap.has(target.get_instance_id()):
		return
	
	var mark = prefab.instance()
	mark.set_target(target)
	add_child(mark)
	
	markmap[target.get_instance_id()] = mark

func removeMarkForEnemyInstanceId(enemyInstanceId):
	if !markmap.has(enemyInstanceId):
		return 
		
	var child = markmap[enemyInstanceId]
	child.queue_free()
	
	markmap.erase(enemyInstanceId)
