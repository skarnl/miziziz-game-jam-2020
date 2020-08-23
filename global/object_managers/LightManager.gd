extends ObjectManager

var enemyLightPrefab = preload('res://entities/world/enemy_light.tscn')
var bloodLightPrefab = preload('res://entities/world/blood_light.tscn')

func addLightToTarget(target, type):
	match type:
		'enemy':
			_addToTarget(target, enemyLightPrefab)
		'blood':
			_addToTarget(target, bloodLightPrefab)
