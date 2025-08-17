extends Node

var music_player: AudioStreamPlayer

func _ready():
	# Create a global music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# Load your background music
	var music = load("res://assets/music_and_sounds/background_music.mp3")  # Adjust path
	music_player.stream = music
	
	# Set it to loop and adjust volume
	music_player.autoplay = true
	#music_player.volume_db = 30  # Quieter so it doesn't overpower dialogue
	
	# Start playing
	music_player.play()

func set_music_volume(volume_db: float):
	music_player.volume_db = volume_db

func stop_music():
	music_player.stop()

func play_music():
	music_player.play()

func fade_out_music(duration: float = 2.0):
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80, duration)
	await tween.finished
	music_player.stop()

func fade_in_music(duration: float = 2.0):
	music_player.volume_db = -80
	music_player.play()
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -15, duration)
