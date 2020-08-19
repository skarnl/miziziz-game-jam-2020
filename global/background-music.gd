extends Node

var should_swap = false

const NORMAL_VOLUME = -3
const SILENCE_VOLUME = -80

var playing_count = 0

func _ready():
	$Timer.connect('timeout', self, '_tick')
	$Timer.wait_time = $AudioStreamPlayer1.stream.get_length()
	$Timer.start()
	
	yield(get_tree(), 'idle_frame')
	
	for child in get_audio_tracks():
		child.play()
		silence_track(child)
	
	start_random_streams()

# get all AudioStreamPlayers and return it shuffled
func get_audio_tracks():
	randomize()
	var tracks = []
	
	for child in get_children():
		if child is AudioStreamPlayer:
			tracks.append(child)
	
	tracks.shuffle()
	return tracks


func play_track(track):
	track.set_volume_db(NORMAL_VOLUME)
	playing_count += 1
	
	print('play track:', track.name, playing_count)

func silence_track(track):
	track.set_volume_db(SILENCE_VOLUME)
	playing_count = max(playing_count - 1, 0)
	
	print('silence track:', track.name, playing_count)


func is_playing(track):
	return track.get_volume_db() > SILENCE_VOLUME

func start_random_streams():
	randomize()
	var tracks = get_audio_tracks()
	var randomized_tracks = tracks.duplicate()
	
	var count = 0
	for track in randomized_tracks:
		if is_playing(track) == false:
			play_track(track)	
			count += 1
		
		if count == 3:
			return
	
func silence_random_track():
	var tracks = get_audio_tracks()
	for track in tracks:
		if is_playing(track):
			silence_track(track)
			return
	
func start_random_track():
	var tracks = get_audio_tracks()
	for track in tracks:
		if !is_playing(track):
			play_track(track)
			return
	
func replace_random_track():
	randomize()
	var percent = randf()
	
	if playing_count > 2:
		silence_random_track()
	else:
		percent = 1
		
	if (percent > 0.2):
		start_random_track()
	
func _tick():
	print('#tick')
	replace_random_track()
	
	if should_swap:
		pass


func bounce():
	should_swap = true
