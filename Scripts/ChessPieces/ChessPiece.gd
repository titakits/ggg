extends Node2D

@onready var field_size = get_parent().get_parent().field_size
@onready var collision_shape = $Area2D/CollisionShape2D 
@onready var board = get_parent().get_parent().get_parent().get_node("Board")

@export var possible_direct_moves: Array[Vector2]
@export var possible_jump_moves: Array[Vector2]
@export var is_white = true 

var is_selected = false
var follow_target = null  
var initial_position = Vector2.ZERO  

const EPSILON = 100.0 #corrects small positions differences in the floating point number

func is_valid_move(target_position: Vector2) -> bool:
	var start_grid = Vector2(
		int(round(initial_position.x / field_size.x)),
		int(round(initial_position.y / field_size.y)))
	var end_grid = Vector2(
		int(round(target_position.x / field_size.x)),
		int(round(target_position.y / field_size.y)))
	var move = end_grid - start_grid
	for possible_move in possible_direct_moves:
		if Vector2(sign(move.x), sign(move.y)) == Vector2(sign(possible_move.x), sign(possible_move.y)): 
			if (move.x == 0 or move.y == 0) or (abs(move.x) == abs(move.y)):
				if abs(move.x) <= abs(possible_move.x) and abs(move.y) <= abs(possible_move.y):
					if is_path_clear(start_grid, end_grid):
						return check_target_position(target_position)
	return false

func is_path_clear(start_grid: Vector2, end_grid: Vector2) -> bool:
	var delta_grid = end_grid - start_grid
	var steps = max(abs(delta_grid.x), abs(delta_grid.y))
	var step_x = sign(delta_grid.x)
	var step_y = sign(delta_grid.y)
	for i in range(1, int(steps)):
		var current_grid_pos = start_grid + Vector2(step_x * i, step_y * i)
		var current_world_pos = Vector2(
			current_grid_pos.x * field_size.x,
			current_grid_pos.y * field_size.y)
		if is_field_occupied(current_world_pos):
			return false
	return true

func check_target_position(target_position: Vector2) -> bool:
	var piece_at_target = is_field_occupied(target_position)
	if piece_at_target:
		if piece_at_target.is_white != self.is_white:
			print("Can capture opponent's piece at position: ", target_position)
			return true  # Can capture opponent's piece
		else:
			print("Cannot capture own piece at position: ", target_position)
			return false  # Can't capture own piece
	else:
		return true  # Move to empty square

func is_field_occupied(position: Vector2) -> Node2D:
	for child in board.get_children():
		for piece in child.get_children():
			if piece is Node2D and piece != self and piece.has_method("move_to"):
				if piece.global_position.distance_to(position) < EPSILON:
					return piece  # Return the piece at the position
	return null

func move_to(target_position):
	position = target_position

func _process(_delta):
	if is_selected and follow_target:
		var target_position = follow_target.global_position
		global_position = global_position.lerp(target_position, 0.1)  # Adjust 0.1 for smoothing speed

func is_field_valid(target_position: Vector2) -> bool:
	return !is_field_occupied(target_position)

func attack(_target):
	# Handle attack logic here
	pass

#func play_animation(animation_name):
	#if $AnimatedSprite:
		#$AnimatedSprite.play(animation_name)
