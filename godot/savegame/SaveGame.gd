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
	
	var save_game = null
	
	if OS.is_debug_build():
		save_game = FileAccess.open("user://" + SAVE_GAME_TEMPLATE, FileAccess.WRITE)
	else:
		save_game = FileAccess.open_encrypted_with_pass("user://" + SAVE_GAME_TEMPLATE, FileAccess.WRITE, ENCRYPTION_KEY)
		
	var save_nodes = tree.get_nodes_in_group(SAVE_GROUP_NAME)
	
	for node in save_nodes:
		
		var save_data = {}
		
		# Check the node is an instanced scene so it can be instanced again during load.
		if not node.scene_file_path.is_empty():
			save_data["scene_file_path"] = node.scene_file_path
			
		if not node.get_path().is_empty():
			save_data["path"] = node.get_path()
			
		if "position" in node:
			save_data["pos_x"] = node.position.x
			save_data["pos_y"] = node.position.y
			if node.position is Vector3:
				save_data["pos_z"] = node.position.z
				
		if "rotation" in node:
			save_data["rotation"] = node.rotation
			
		if "scale" in node:
			save_data["scale_x"] = node.scale.x
			save_data["scale_y"] = node.scale.y
			if node.scale is Vector3:
				save_data["scale_z"] = node.scale.z

		# Call the node's save function.
		if node.has_method("save_data"):
			save_data["node_data"] = node.call("save_data")
		
		# Store the save dictionary as a new line in the save file.
		save_game.store_line(JSON.new().stringify(save_data))

static func load_game(tree:SceneTree) -> void:
	
	if not ENABLED:
		return

	if not has_save():
		print("No save game found. Skipped loading!")
		return
	
	print("Load game from user://" + SAVE_GAME_TEMPLATE)
		
	var save_nodes = tree.get_nodes_in_group(SAVE_GROUP_NAME)
	
	var nodes_by_scene_file_path = {}
	var nodes_by_path = {}
	for node in save_nodes:
		if not node.scene_file_path.is_empty():
			nodes_by_path[node.scene_file_path] = node
		if not node.get_path().is_empty():
			nodes_by_path[node.get_path()] = node

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = null
	
	if OS.is_debug_build():
		save_game = FileAccess.open("user://" + SAVE_GAME_TEMPLATE, FileAccess.READ)
	else:
		save_game = FileAccess.open_encrypted_with_pass("user://" + SAVE_GAME_TEMPLATE, FileAccess.READ, ENCRYPTION_KEY)
		
	while save_game.get_position() < save_game.get_length():
		# Get the saved dictionary from the next line in the save file
		var test_json_conv = JSON.new()
		test_json_conv.parse(save_game.get_line())
		var save_data = test_json_conv.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		var node = null
		
		if "path" in save_data and nodes_by_path.has(NodePath(save_data.path)):
			node = nodes_by_path[NodePath(save_data.path)]
		elif "scene_file_path" in save_data and nodes_by_scene_file_path.has(save_data.scene_file_path):
			node = nodes_by_scene_file_path[save_data.scene_file_path]
		else:
			push_warning("skipping loading node from save game: node got removed from tree!")
			continue

		if "position" in node:
			if node.scale is Vector2:
				node.position = Vector2(save_data["pos_x"], save_data["pos_y"])
			elif node.scale is Vector3:
				node.position = Vector3(save_data["pos_x"], save_data["pos_y"], save_data["pos_z"])
			
		if "rotation" in node:
			node.rotation = save_data["rotation"]
			
		if "scale" in node:
			if node.scale is Vector2:
				node.scale = Vector2(save_data["scale_x"], save_data["scale_y"])
			elif node.scale is Vector3:
				node.scale = Vector3(save_data["scale_x"], save_data["scale_y"], save_data["scale_z"])
				
		if node.has_method("load_data") and save_data.has("node_data"):
			node.call("load_data", save_data["node_data"])
