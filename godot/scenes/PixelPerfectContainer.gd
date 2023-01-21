extends SubViewportContainer

const OFFSET_PARAM = "offset"

@onready var camera := %Camera2D
@onready var scene := %IngameScene
@onready var position_shader = material as ShaderMaterial

func _process(delta:float) -> void:
	# TODO compute correct position
	#position_shader.set_shader_parameter(OFFSET_PARAM, Vector2(10.0, 0.5))
	# TODO smooth camera position
	camera.global_position = scene.get_camera_target().global_position
