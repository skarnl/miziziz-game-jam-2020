extends Control

func _ready():
	$MusicButton.connect('pressed', self, '_on_MusicButton_pressed')


func _on_MusicButton_pressed():
	BackgroundMusic.toggle_music()
	
	var alpha = 0.5 if BackgroundMusic.get_is_music_muted() else 1
	
	$MusicButton/OnSprite.modulate = Color(1,1,1, alpha)
