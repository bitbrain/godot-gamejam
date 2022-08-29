extends Node2D

@export var main_menu_scene:PackedScene

@onready var overlay:FadeOverlay = %FadeOverlay

func _ready():
	overlay.visible = true

func _on_fade_overlay_on_complete_fade_out():
	get_tree().change_scene_to(main_menu_scene)

func _on_return_button_pressed():
	overlay.fade_out()
