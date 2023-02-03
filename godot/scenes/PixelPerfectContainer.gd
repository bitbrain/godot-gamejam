extends SubViewportContainer

const OFFSET_PARAM = "offset"
const GAME_SIZE := Vector2(162.0 / 4, 92.0 /4 )

@onready var camera := %Camera2D
@onready var scene := %IngameScene
@onready var position_shader = material as ShaderMaterial
@onready var actual_cam_pos:Vector2 = camera.global_position
@onready var window_scale = float(DisplayServer.window_get_size(0).y) / GAME_SIZE.y

func _process(delta:float) -> void:
	var target_position = scene.get_camera_target().global_position + Vector2(8.0, 8.0)
	var mouse_pos = get_viewport().get_mouse_position() / window_scale - (GAME_SIZE / 2.0) + target_position
	var cam_pos = lerp(target_position, mouse_pos, 0.7)
	
	actual_cam_pos = lerp(actual_cam_pos, cam_pos, delta * 5.0)
	
	var subpixel_position = actual_cam_pos.floor() - actual_cam_pos
	
	position_shader.set_shader_parameter(OFFSET_PARAM, subpixel_position)
	camera.global_position = actual_cam_pos.floor()

