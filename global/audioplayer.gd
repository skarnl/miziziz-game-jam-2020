extends Node

func play(name):
	match(name):
		'possess':
			$intoBodyAudio.play()
		'exit_possess':
			$outofBodyAudio.play()
		'spawn':
			$spawnAudio.play()
		'splash':
			$splashAudio.play()
