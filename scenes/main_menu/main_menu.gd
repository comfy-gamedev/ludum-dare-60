extends Node2D

func _ready() -> void:
	MusicMan.cue_music("troubles")
	$VolumeVSlider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))

func _on_tutor_1_pressed() -> void:
	SceneGirl.change_scene("res://scenes/tutorials/tutor_1.tscn")

func _on_tutor_2_pressed() -> void:
	SceneGirl.change_scene("res://scenes/tutorials/tutor_2.tscn")
	
func _on_tutor_3_pressed() -> void:
	SceneGirl.change_scene("res://scenes/tutorials/tutor_3.tscn")
	
func _on_tutor_4_pressed() -> void:
	SceneGirl.change_scene("res://scenes/tutorials/tutor_4.tscn")
	
func _on_tutor_5_pressed() -> void:
	SceneGirl.change_scene("res://scenes/tutorials/tutor_5.tscn")


func _on_button_pressed() -> void:
	SceneGirl.change_scene("res://scenes/main/main.tscn")

func _on_button_2_pressed() -> void:
	Globals.is_easy = true
	SceneGirl.change_scene("res://scenes/main/main.tscn")


func _on_volume_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)
