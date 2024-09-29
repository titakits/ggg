extends Node2D

const FIELD_SCENE_PATH = "res://Scenes/field.tscn"

@export var piece_spawns: Dictionary = {}  # Initialize as empty dictionary

# Size of the board
const BOARD_SIZE = 8

# Size of each field
const FIELD_SIZE = Vector2(2200, 1400)  # Adjust based on your field size

# Hardcoded dictionary to map coordinates to chess notation
var coordinate_to_field_name = {
	"0,0": "A8", "1,0": "B8", "2,0": "C8", "3,0": "D8", "4,0": "E8", "5,0": "F8", "6,0": "G8", "7,0": "H8",
	"0,1": "A7", "1,1": "B7", "2,1": "C7", "3,1": "D7", "4,1": "E7", "5,1": "F7", "6,1": "G7", "7,1": "H7",
	"0,2": "A6", "1,2": "B6", "2,2": "C6", "3,2": "D6", "4,2": "E6", "5,2": "F6", "6,2": "G6", "7,2": "H6",
	"0,3": "A5", "1,3": "B5", "2,3": "C5", "3,3": "D5", "4,3": "E5", "5,3": "F5", "6,3": "G5", "7,3": "H5",
	"0,4": "A4", "1,4": "B4", "2,4": "C4", "3,4": "D4", "4,4": "E4", "5,4": "F4", "6,4": "G4", "7,4": "H4",
	"0,5": "A3", "1,5": "B3", "2,5": "C3", "3,5": "D3", "4,5": "E3", "5,5": "F3", "6,5": "G3", "7,5": "H3",
	"0,6": "A2", "1,6": "B2", "2,6": "C2", "3,6": "D2", "4,6": "E2", "5,6": "F2", "6,6": "G2", "7,6": "H2",
	"0,7": "A1", "1,7": "B1", "2,7": "C1", "3,7": "D1", "4,7": "E1", "5,7": "F1", "6,7": "G1", "7,7": "H1"
}

func _ready():
	var field_scene = load(FIELD_SCENE_PATH) as PackedScene

	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			var field_instance = field_scene.instantiate()
			if not field_instance:
				print("Error: Failed to instantiate field scene.")
				return
			add_child(field_instance)
			field_instance.position = Vector2(x * FIELD_SIZE.x, y * FIELD_SIZE.y)
			field_instance.name = "Field_%d_%d" % [x, y]

			# Spawn the pieces in the correct positions
			var field_name = coordinate_to_field_name["%d,%d" % [x, y]]
			if piece_spawns.has(field_name):
				var piece_scene = piece_spawns[field_name] as PackedScene
				if piece_scene:
					var piece_instance = piece_scene.instantiate()
					field_instance.add_child(piece_instance)
					piece_instance.position = field_instance.get_node("Platform0").position
			

# Function to map coordinates to chess notation using the hardcoded dictionary
func get_field_name(x: int, y: int) -> String:
	return coordinate_to_field_name["%d,%d" % [x, y]]
	
func world_to_map(world_pos: Vector2) -> Vector2:
	return Vector2(
		floor(world_pos.x / FIELD_SIZE.x),
		floor(world_pos.y / FIELD_SIZE.y)
	)
