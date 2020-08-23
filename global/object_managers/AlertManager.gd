extends ObjectManager

var questionMarkPrefab = preload('res://gui/QuestionMark.tscn')
var alertMarkPrefab = preload('res://gui/AlertMark.tscn')

func addMarkToTarget(target, markType):
	match(markType):
		'question':
			_addToTarget(target, questionMarkPrefab)
		'alert':
			_addToTarget(target, alertMarkPrefab)
