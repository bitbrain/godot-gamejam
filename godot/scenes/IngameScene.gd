class_name IngameScene extends Node2D

@onready var pixel_frog := $PixelFrog

func get_camera_target() -> Node2D:
	return pixel_frog
