extends Node
## A music and sfx player which automates AudioStreamPlayer nodes.
##
## Music is played on the "Music" audio bus.
## Sound effects are played on the "SFX" audio bus.

@onready var music: AudioStreamPlayer = $Music
@onready var audio_events: Node = $AudioEvents
@onready var track_label: Control = %TrackLabel


## Plays music.
## [param stream]: the music stream name to play.
func cue_music(track: String) -> void:
	var pb: AudioStreamPlaybackInteractive = music.get_stream_playback()
	if track == music.stream.get_clip_name(pb.get_current_clip_index()):
		return
	
	pb.switch_to_clip_by_name(track)
	
	while track_label.is_playing:
		await track_label.finished
	track_label.text = "♫ " + track
	track_label.play_async()


## Plays a sound effect. Does not support positional audio.
## [param event_name]: the name of the node in audio_events.tscn.
func event(event_name: String) -> void:
	var asp = audio_events.get_node(event_name)
	if asp is AudioStreamPlayer:
		asp.play()
	elif asp is AudioStreamPlayer3D:
		push_error("Must use event_3d for 3D audio")
		breakpoint


## Plays a sound effect. Does not support positional audio.
## This function bypasses polyphony. Best used for small repeated sfx.
## [param event_name]: the name of the node in audio_events.tscn.
func event_oneshot(event_name: String, vp: Viewport) -> void:
	var asp = audio_events.get_node(event_name)
	if asp is AudioStreamPlayer:
		var nasp = asp.duplicate()
		vp.add_child(nasp)
		nasp.finished.connect(nasp.queue_free)
		nasp.play()
	elif asp is AudioStreamPlayer3D:
		push_error("Must use event_3d for 3D audio")
		breakpoint


## Plays a sound effect in 3D space.
## This function bypasses polyphony. Best used for small repeated sfx.
## [param event_name]: the name of the node in audio_events.tscn.
func event_oneshot_3d(event_name: String, vp: Viewport, position: Vector3) -> void:
	var asp = audio_events.get_node(event_name)
	if asp is AudioStreamPlayer3D:
		var nasp = asp.duplicate()
		nasp.position = position
		vp.add_child(nasp)
		nasp.finished.connect(nasp.queue_free)
		nasp.play()
	else:
		push_error("Event is not 3D")
		breakpoint
