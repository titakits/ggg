extends Area2D

var selected_chess_piece = null
var nearby_chess_piece = null

@onready var board = get_parent().get_parent().get_node("Board")
@onready var player = get_parent()  

func _ready():
	if not is_connected("body_entered", Callable(self, "_on_area_2d_body_entered")):
		connect("body_entered", Callable(self, "_on_area_2d_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_area_2d_body_exited")):
		connect("body_exited", Callable(self, "_on_area_2d_body_exited"))
		
	#var timer: Timer = Timer.new()
	#add_child(timer)
	#timer.wait_time = 1.0  # Set the timer to 1 second
	#timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	#timer.start()
 
func _on_area_2d_body_entered(body: Node2D):
	if body is StaticBody2D:
		var parent_piece = body.get_parent()
		if parent_piece.get_class() == "Node2D" and parent_piece.has_method("move_to"):
			if parent_piece != selected_chess_piece:
				nearby_chess_piece = parent_piece

func _on_area_2d_body_exited(body: Node2D):
	if body is StaticBody2D:
		var parent_piece = body.get_parent()
		if parent_piece == nearby_chess_piece:
			nearby_chess_piece = null

func select_chess_piece():
	if nearby_chess_piece:
		selected_chess_piece = nearby_chess_piece
		selected_chess_piece.is_selected = true
		selected_chess_piece.follow_target = player
		selected_chess_piece.initial_position = selected_chess_piece.global_position  
		nearby_chess_piece = null

func move_chess_piece(current_platform):
	if current_platform and selected_chess_piece and current_platform.target_field_name == "":
		var target_position = current_platform.global_position
		var move_valid = selected_chess_piece.is_valid_move(target_position)
		if move_valid:
			selected_chess_piece.global_position = current_platform.global_position
			selected_chess_piece.is_selected = false
			selected_chess_piece.follow_target = null
			selected_chess_piece = null
			#reparent chesspiece to new field
