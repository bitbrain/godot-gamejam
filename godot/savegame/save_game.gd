## Script that manages saving games.
class_name SaveGame extends Node

const ENABLED = true
const ENCRYPTION_KEY = "godotrules"
const SAVE_GAME_TEMPLATE = "savegame.save"
const SAVE_GROUP_NAME = "Persist"
const NODE_DATA = "node_data"

static func delete_save() -> void:
	
	if not ENABLED:
		return
		
	DirAccess.remove_absolute("user://" + SAVE_GAME_TEMPLATE)

static func has_save() -> bool:
	return FileAccess.file_exists("user://" + SAVE_GAME_TEMPLATE)

static func save_game(tree:SceneTree):
	
	if not ENABLED:
		return
	
	print("Saving game to user://" + SAVE_GAME_TEMPLATE)
	
	var save_file = null
	
	if OS.is_debug_build():
		save_file = FileAccess.open("user://" + SAVE_GAME_TEMPLATE, FileAccess.WRITE)
	else:
		save_file = FileAccess.open_encrypted_with_pass("user://" + SAVE_GAME_TEMPLATE, FileAccess.WRITE, ENCRYPTION_KEY)
		
	var save_nodes = tree.get_nodes_in_group(SAVE_GROUP_NAME)
	
	for node in save_nodes:
		
		var save_data = {}
		
		# Check the node is an instanced scene so it can be instanced again during load.
		if not node.scene_file_path.is_empty():
			save_data["scene_file_path"] = node.scene_file_path
			
		if not node.get_path().is_empty():
			save_data["path"] = node.get_path()
			
		if not node.get_parent().get_path().is_empty():
			save_data["parent"] = node.get_parent().get_path()
			
		if "position" in node:
			save_data["pos_x"] = node.position.x
			save_data["pos_y"] = node.position.y
			if node.position is Vector3:
				save_data["pos_z"] = node.position.z
				
		if node is Node2D:
			save_data["rotation"] = node.rotation
		elif node is Node3D:
			save_data["rotation_x"] = node.rotation.x
			save_data["rotation_y"] = node.rotation.y
			save_data["rotation_z"] = node.rotation.z

		if "scale" in node:
			save_data["scale_x"] = node.scale.x
			save_data["scale_y"] = node.scale.y
			if node.scale is Vector3:
				save_data["scale_z"] = node.scale.z
	
		save_data["visible"] = node.visible

		if node is CanvasItem:
			save_data["modulate_r"] = node.modulate.r
			save_data["modulate_g"] = node.modulate.g
			save_data["modulate_b"] = node.modulate.b
			save_data["modulate_a"] = node.modulate.a

		# Call the node's save function.
		if node.has_method("save_data"):
			save_data["node_data"] = node.call("save_data")
		
		# Store the save dictionary as a new line in the save file.
		save_file.store_line(JSON.stringify(save_data))

static func load_game(tree:SceneTree) -> void:
	
	if not ENABLED:
		return

	if not has_save():
		print("No save game found. Skipped loading!")
		return
	
	print("Load game from user://" + SAVE_GAME_TEMPLATE)
		
	var save_nodes = tree.get_nodes_in_group(SAVE_GROUP_NAME)
	
	var nodes_by_path = {}
	for node in save_nodes:
		if not node.get_path().is_empty():
			nodes_by_path[node.get_path()] = node

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = null
	
	if OS.is_debug_build():
		save_file = FileAccess.open("user://" + SAVE_GAME_TEMPLATE, FileAccess.READ)
	else:
		save_file = FileAccess.open_encrypted_with_pass("user://" + SAVE_GAME_TEMPLATE, FileAccess.READ, ENCRYPTION_KEY)
		
	while save_file.get_position() < save_file.get_length():
		# Get the saved dictionary from the next line in the save file
		var test_json_conv = JSON.new()
		test_json_conv.parse(save_file.get_line())
		var save_data = test_json_conv.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		var node = null
		
		if "path" in save_data and nodes_by_path.has(NodePath(save_data.path)):
			node = nodes_by_path[NodePath(save_data.path)]
			nodes_by_path.erase(NodePath(save_data.path))
		elif "path" in save_data and "parent" in save_data and "scene_file_path" in save_data:
			# node is not present in tree so it was dynamically added at runtime
			var parent = tree.root.get_node(NodePath(save_data["parent"]))
			node = load(save_data["scene_file_path"]).instantiate()
			parent.add_child(node)
		else:
			push_warning("skipping loading node from save game: node got moved.")
			continue

		if "position" in node:
			if node.scale is Vector2:
				node.position = Vector2(save_data["pos_x"], save_data["pos_y"])
			elif node.scale is Vector3:
				node.position = Vector3(save_data["pos_x"], save_data["pos_y"], save_data["pos_z"])
			
		if node is Node2D:
			node.rotation = save_data["rotation"]
		elif node is Node3D:
			node.rotation = Vector3(save_data["rotation_x"], save_data["rotation_y"], save_data["rotation_z"])
			
		if "scale" in node:
			if node.scale is Vector2:
				node.scale = Vector2(save_data["scale_x"], save_data["scale_y"])
			elif node.scale is Vector3:
				node.scale = Vector3(save_data["scale_x"], save_data["scale_y"], save_data["scale_z"])
				
		if save_data.has("visible") and "visible" in node:
			node.visible = save_data["visible"]
		
		if node is CanvasItem:
			node.modulate = Color(save_data["modulate_r"], save_data["modulate_g"], save_data["modulate_b"], save_data["modulate_a"])
				
		if node.has_method("load_data") and save_data.has("node_data"):
			node.call("load_data", save_data["node_data"])
	
	# delete any node from scene that was not persisted into the save file
	# but is currently tagged as "Persisted" -> this means node got removed in the meantime
	for key in nodes_by_path:
		var node = nodes_by_path[key]
		node.queue_free()
