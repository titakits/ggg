extends StaticBody2D

var target_field_name = ""
var parent_field_name = "" 
var player_in_area = false

func _ready():
	call_deferred("_setup_platform")

func _setup_platform():
	var board = get_parent().get_parent().get_parent().get_node("Board")
	parent_field_name = get_parent().name
	var field_coords = board.get_field_coordinates(parent_field_name)
	var x = field_coords.x
	var y = field_coords.y
	match name:
		"Platform0":
			target_field_name = ""  # No teleport
		"Platform1":  # Top
			target_field_name = try_get_field_name(board, x, y - 1)
		"Platform2":  # Top-right
			target_field_name = try_get_field_name(board, x + 1, y - 1)
		"Platform3":  # Right
			target_field_name = try_get_field_name(board, x + 1, y)
		"Platform4":  # Bottom-right
			target_field_name = try_get_field_name(board, x + 1, y + 1)
		"Platform5":  # Bottom
			target_field_name = try_get_field_name(board, x, y + 1)
		"Platform6":  # Bottom-left
			target_field_name = try_get_field_name(board, x - 1, y + 1)
		"Platform7":  # Left
			target_field_name = try_get_field_name(board, x - 1, y)
		"Platform8":  # Top-left
			target_field_name = try_get_field_name(board, x - 1, y - 1)

	if name != "Platform0" and (target_field_name == "" or not board.has_node(target_field_name)):
		queue_free()
	else:
		if has_node("Area2D"):
			var area = $Area2D
			area.connect("body_entered", Callable(self, "_on_Area2D_body_entered"))
			area.connect("body_exited", Callable(self, "_on_Area2D_body_exited"))

func try_get_field_name(board, x, y):
	if x < 0 or x >= 8 or y < 0 or y >= 8:
		return ""
	return board.get_field_name(x, y)

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		body.set("current_platform", self)

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		body.set("current_platform", null)
