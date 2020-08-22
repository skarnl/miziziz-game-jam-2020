extends Node

var should_swap = false

const NORMAL_VOLUME = -10
const SILENCE_VOLUME = -80

var playing_count = 0

func _ready():	
	$Timer.connect('timeout', self, '_tick')
	$Timer.wait_time = $AudioStreamPlayer1.stream.get_length() * 2 # every 2 'rounds' we swap
	$Timer.start()
	
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
	
func silence_track(track):
	track.set_volume_db(SILENCE_VOLUME)
	playing_count = max(playing_count - 1, 0)
	
func is_playing(track):
	return track.get_volume_db() > SILENCE_VOLUME

func start_random_streams():
	var tracks = get_audio_tracks()
	var randomized_tracks = tracks.duplicate()
	
	# start either stream 4 or 6 - one of the base tracks
	var percent = randf()
	if percent > 0.5:
		play_track($AudioStreamPlayer4)
	else:
		play_track($AudioStreamPlayer6)
	
	# add 2 more tracks to start with
	var count = 0
	for track in randomized_tracks:
		if is_playing(track) == false:
			play_track(track)	
			count += 1
		
		if count == 2:
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
			break
	
func check_at_least_one_mandatory_track_is_playing():
	var tracks = get_audio_tracks()
	for track in tracks:
		if is_playing(track) and (track.name == 'AudioStreamPlayer4' or track.name == 'AudioStreamPlayer6'):
			return true
			
	return false
	
func replace_random_track():
	randomize()
	var percent = randf()
	
	if playing_count > 2:
		silence_random_track()
	else:
		percent = 1
		
	if (percent > 0.2):
		start_random_track()
		
	# check at least wav4 of wav6 are playing
	if !check_at_least_one_mandatory_track_is_playing():
		replace_random_track()
	
func _tick():
	replace_random_track()
	
	if should_swap:
		pass


func bounce():
	should_swap = true
