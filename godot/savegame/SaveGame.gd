## Script that manages saving games.
class_name SaveGame extends Node

const ENABLED = true
const SAVEGAME_VERSION = 1
const ENCRYPTION_KEY = "godotrules"
const SAVE_GAME_TEMPLATE = "savegame.save"
const SAVE_GROUP_NAME = "Persist"

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
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save_data"):
			print("persistent node '%s' is missing a save_data() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save_data")
		
		# Store the save dictionary as a new line in the save file.
		save_game.store_line(JSON.new().stringify(node_data))

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
		nodes_by_path[node.scene_file_path] = node

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
		var node_data = test_json_conv.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		if node_data == null or (!("scene_file_path" in node_data) and !("node_path" in node_data)):
			push_warning("ignoring node data at save position %s - no scene_file_path specified." % str(save_game.get_position()))
			continue
		var node = null
		if "create_on_load" in node_data and node_data["create_on_load"]:
			node = load(node_data["scene_file_path"]).instantiate()
			# FIXME: Dirty hack for now!
		else:
			if "scene_file_path" in node_data and nodes_by_path.has(node_data.scene_file_path):
				node = nodes_by_path[node_data.scene_file_path]
			else:
				push_warning("skipping loading node from save game: node got removed from tree!")
				continue
		if "position" in node and "pos_x" in node_data and "pos_y" in node_data:
			node.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "scene_file_path" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			if i in node:
				node.set(i, node_data[i])
				
		if node.has_method("load_data"):
			node.call("load_data", node_data)
