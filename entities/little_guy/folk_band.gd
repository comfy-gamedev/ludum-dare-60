extends Node2D

@onready var folk_band_player: AnimationPlayer = $FolkBandPlayer

func _ready() -> void:
	folk_band_player.play("FolkBandAnimation")
