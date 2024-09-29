extends StaticBody2D

# Instance variables
var target_field_name = ""
var player_in_area = false
var parent_field_name = ""  # Declare parent_field_name at the class level

func _ready():
	# Defer setup until the node is fully added to the scene tree
	call_deferred("_setup_platform")

func _setup_platform():
	# Find the board node dynamically
	var board = find_board_node()
	if board == null:
		return

	# Set up the target field based on the platform's position
	parent_field_name = get_parent().name  # Assign to instance variable
	var field_coords = parent_field_name.split("_")
	if field_coords.size() != 3:
		return

	var x = int(field_coords[1])
	var y = int(field_coords[2])

	match name:
		"Platform0":  # Central platform, no teleport
			target_field_name = ""
		"Platform1":  # Top
			target_field_name = "Field_%d_%d" % [x, y-1]
		"Platform2":  # Top-right
			target_field_name = "Field_%d_%d" % [x+1, y-1]
		"Platform3":  # Right
			target_field_name = "Field_%d_%d" % [x+1, y]
		"Platform4":  # Bottom-right
			target_field_name = "Field_%d_%d" % [x+1, y+1]
		"Platform5":  # Bottom
			target_field_name = "Field_%d_%d" % [x, y+1]
		"Platform6":  # Bottom-left
			target_field_name = "Field_%d_%d" % [x-1, y+1]
		"Platform7":  # Left
			target_field_name = "Field_%d_%d" % [x-1, y]
		"Platform8":  # Top-left
			target_field_name = "Field_%d_%d" % [x-1, y-1]

	if name != "Platform0" and (target_field_name == "" or not board.has_node(target_field_name)):
		queue_free()
	else:
		if has_node("Area2D"):
			var area = $Area2D
			area.connect("body_entered", Callable(self, "_on_Area2D_body_entered"))
			area.connect("body_exited", Callable(self, "_on_Area2D_body_exited"))

func find_board_node():
	var current = self
	while current:
		if current.has_node("Board"):
			return current.get_node("Board")
		current = current.get_parent()
	return null

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		body.set("current_platform", self)

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		body.set("current_platform", null)
