extends Control

var backgroundMusicBusId
var sfxBusId

func _ready():
	$MusicButton.connect('pressed', self, '_on_MusicButton_pressed')
	$SFXButton.connect('pressed', self, '_on_SFXButton_pressed')
	
	backgroundMusicBusId = AudioServer.get_bus_index('BackgroundMusic')
	sfxBusId = AudioServer.get_bus_index('SFX')

func _on_MusicButton_pressed():
	var is_muted = AudioServer.is_bus_mute(backgroundMusicBusId)
	AudioServer.set_bus_mute(backgroundMusicBusId, !is_muted)
	
	var alpha = 0.5 if !is_muted else 1
	
	$MusicButton/OnSprite.modulate = Color(1,1,1, alpha)

func _on_SFXButton_pressed():
	var is_muted = AudioServer.is_bus_mute(sfxBusId)
	AudioServer.set_bus_mute(sfxBusId, !is_muted)
	
	if is_muted:
		$SFXButton/OnSprite.show()
		$SFXButton/OffSprite.hide()
	else:
		$SFXButton/OffSprite.show()
		$SFXButton/OnSprite.hide()
