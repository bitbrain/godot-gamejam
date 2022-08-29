extends Node2D

@export var game_scene:PackedScene
@export var settings_scene:PackedScene

@onready var overlay:FadeOverlay = %FadeOverlay
@onready var play_button:Button = %PlayButton
@onready var settings_button:Button = %SettingsButton

var next_scene = game_scene

func _ready() -> void:
	overlay.visible = true
	play_button.disabled = game_scene == null
	settings_button.disabled = settings_scene == null

func _on_settings_button_pressed():
	next_scene = settings_scene
	overlay.fade_out()
	
func _on_play_button_pressed():
	next_scene = game_scene
	overlay.fade_out()

func _on_exit_button_pressed():
	get_tree().quit()

func _on_fade_overlay_on_complete_fade_out():
	get_tree().change_scene_to(next_scene)
