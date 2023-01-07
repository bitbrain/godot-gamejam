extends Sprite2D

# specify in nodes to load data
# from save game for this node
func load_data(data:Dictionary) -> void:
	print(data.hello) 
	
# specify in nodes to save data
# of this node to the save game
func save_data() -> Dictionary:
	return {
		"hello": "Hello Godot!"
	}
	
func _process(delta):
	if Input.is_action_pressed("ui_right"):
		position.x += 100 * delta
	if Input.is_action_pressed("ui_left"):
		position.x -= 100 * delta
	if Input.is_action_pressed("ui_up"):
			position.y -= 100 * delta
	if Input.is_action_pressed("ui_down"):
		position.y += 100 * delta
