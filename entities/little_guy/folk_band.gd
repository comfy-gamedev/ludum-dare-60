extends Node2D
@onready var folk_band_player: AnimationPlayer = $FolkBandPlayer
@onready var folk_band: Node2D = $"."


func _ready() -> void:
	var fb = folk_band_player.instantiate()
	AnimationPlayer.play(fb)
