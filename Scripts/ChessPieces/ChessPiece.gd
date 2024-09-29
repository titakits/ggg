extends Node2D

@export var possible_moves: Array[Vector2]
@export var jump_moves: Array[Vector2]
@export var can_jump_flag = false
var FIELD_SIZE = Vector2.ZERO
var is_selected = false
var follow_target = null  # The target (player) to follow
var initial_position = Vector2.ZERO  # Store the initial position when selected
@export var is_white = true  # Flag to determine if the piece is white or black

@onready var collision_shape = $Area2D/CollisionShape2D  # Ensure this node exists
const EPSILON = 10.0

var is_chess_piece = true

func set_possible_moves(moves):
	possible_moves = moves

func get_possible_moves():
	return possible_moves

func set_jump_moves(moves):
	jump_moves = moves

func get_jump_moves():
	return jump_moves

func set_can_jump(jump):
	can_jump_flag = jump

func can_jump():
	return can_jump_flag

func set_FIELD_SIZE(size):
	FIELD_SIZE = size

func disable_collision():
	collision_shape.disabled = true

func enable_collision():
	collision_shape.disabled = false
	
func is_valid_move(target_position: Vector2, board: Node2D) -> bool:
	var move = (target_position - initial_position) / FIELD_SIZE
	move.x = round(move.x)
	move.y = round(move.y)
	print("Checking move: ", move)

	for possible_move in possible_moves:
		print("Checking against possible move: ", possible_move)
		if abs(move.x) <= abs(possible_move.x) and abs(move.y) <= abs(possible_move.y):
			print("Move is within possible range")
			var direction = Vector2(sign(move.x), sign(move.y))
			var current_position = initial_position
			var steps = max(abs(move.x), abs(move.y))

			for step in range(1, steps + 1):
				current_position += direction * FIELD_SIZE
				print("Checking position: ", current_position)

				if step < steps:
					# Check intermediate positions for obstructions
					if is_field_occupied(current_position, board):
						print("Field not valid at ", current_position)
						return false  # Path is blocked
				else:
					# Handle the target position
					var piece_at_target = is_field_occupied(current_position, board)
					if piece_at_target:
						if piece_at_target.is_white == self.is_white:
							print("Cannot capture own piece at position: ", current_position)
							return false  # Can't capture own piece
						else:
							print("Can capture opponent's piece at position: ", current_position)
							# Optionally handle capturing logic here
					# If the target position is empty or occupied by an opponent, the move is valid
					return true

			# If we've gone through all steps and haven't returned, it's a valid move
			print("Completed all steps, move is valid")
			return true

	# If we've checked all possible moves and haven't returned, it's not a valid move
	print("Move is not within any possible move range")
	return false
	
func is_field_occupied(position: Vector2, board: Node2D) -> Node2D:
	for piece in board.get_children():
		if piece is Node2D and piece != self and piece.has_method("move_to"):
			if piece.global_position.distance_to(position) < EPSILON:
				return piece  # Return the piece at the position
	return null


func get_field_name(position: Vector2, board: Node2D) -> String:
	for field in board.get_children():
		if field.position == position:
			return field.name
	return "No field"

func is_field_valid(target_position: Vector2, board: Node2D) -> bool:
	for piece in board.get_children():
		if piece is Node2D and piece != self and piece.has_method("move_to"):  # Check if it's a chess piece
			if piece.global_position.distance_to(target_position) < EPSILON:
				print("Piece found at position: ", target_position)
				return false  # Field is occupied by another piece
	print("No piece at position: ", target_position)
	return true  # Field is empty

func _process(_delta):
	if is_selected and follow_target:
		var target_position = follow_target.global_position
		global_position = global_position.lerp(target_position, 0.1)  # Adjust 0.1 for smoothing speed


func get_field_name_by_position(position: Vector2, board: Node2D) -> String:
	for field in board.get_children():
		if field is Node2D:
			if field.global_position.distance_to(position) < EPSILON:
				return field.name
	return "No field"

func move_to(target_position):
	position = target_position

func attack(_target):
	# Handle attack logic here
	pass

#func play_animation(animation_name):
	#if $AnimatedSprite:
		#$AnimatedSprite.play(animation_name)
