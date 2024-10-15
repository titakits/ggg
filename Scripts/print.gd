extends Node2D

@onready var board = $"../Board"  # Adjust this path if necessary
var selected_piece = null  # To store the selected piece

#func _ready(): ##Might need this on chesspiece.gd when i want to check if path is clear
	#print("All pieces on the board:")
	#find_and_print_pieces(board)
#
#func find_and_print_pieces(parent_node):
	#for child in parent_node.get_children():
		#if child is Node2D and "possible_moves" in child:
			#var board_position = child.global_position / board.FIELD_SIZE 
			#var field_name = board.get_field_name(int(board_position.x), int(board_position.y))
			#print("Piece:", child.name, "Field:", field_name)
		#else:
			#find_and_print_pieces(child)

func _process(_delta):
	if Input.is_action_just_pressed("ui_interact"): 
		var player = $"../Player/Area2D" 
		if player.selected_chess_piece:
			selected_piece = player.selected_chess_piece
			#print("Selected piece:", selected_piece.name, "Position:", selected_piece.global_position)
			#print_possible_moves(selected_piece)
			
## This should return where the chesspiece can move. 
#func print_possible_moves(piece):
	#if piece and "possible_moves":
		#print("Possible moves for piece: ", piece.name)
		#for move in piece.possible_direct_moves:
			#print(move)
	#else:
		#print("No moves available for this piece.")
