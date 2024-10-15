extends Node2D

@export var piece_spawns: Dictionary = {}

const FIELD_SCENE_PATH = "res://Scenes/field.tscn"
const vertical_fields = 8
const horizontal_fields = 8
const field_size = Vector2(2200, 1400) 

func _ready():
	instantiate_fields()
	print_position_of_pieces()
	
func instantiate_fields():
	var field_scene = load(FIELD_SCENE_PATH) as PackedScene
	for x in range(vertical_fields):
		for y in range(horizontal_fields):
			var field_instance = field_scene.instantiate()
			add_child(field_instance)
			field_instance.position = Vector2(x * field_size.x, y * field_size.y)
			field_instance.name = get_field_name(x, y)
			# Generate the field name programmatically
			var field_name = get_field_name(x, y)
			if field_name != "" and piece_spawns.has(field_name):
				var piece_scene = piece_spawns[field_name] as PackedScene
				if piece_scene:
					var piece_instance = piece_scene.instantiate()
					field_instance.add_child(piece_instance)
					piece_instance.position = field_instance.get_node("Platform0").position

func print_position_of_pieces():
	for child in self.get_children():
		for grandchild in child.get_children():
			if grandchild is Node2D and "possible_direct_moves" in grandchild:
				var board_position = grandchild.global_position / field_size 
				var field_name = get_field_name(int(board_position.x), int(board_position.y))
				print("Piece: ", grandchild.name, "Field: ", field_name)

func get_field_name(x: int, y: int) -> String:
	var columns = ["A", "B", "C", "D", "E", "F", "G", "H"]  
	var column_letter = "" 
	if x >= 0 and x < columns.size():
		column_letter = columns[x]
	else:
		print("Error: x-coordinate out of bounds")
		return ""
	var row_number = 8 - y  
	return "%s%d" % [column_letter, row_number]
	
func get_field_coordinates(field_name: String) -> Vector2:
	var columns = ["A", "B", "C", "D", "E", "F", "G", "H"]
	var column_letter = field_name[0]
	var row_number = field_name[1].to_int()
	var x = columns.find(column_letter)
	var y = 8 - row_number
	return Vector2(x, y)
