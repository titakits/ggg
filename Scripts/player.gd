extends CharacterBody2D

@export var SPEED = 200.0
@export var JUMP_VELOCITY = -900.0
@export var RUN_SPEED = 600.0
@export var DOUBLE_TAP_TIME = 0.25
@export var AIR_CONTROL = .5  # Factor for air control (0.0 to 1.0)
@export var AIR_DASH_SPEED = 1200.0  # Speed for air dash
@export var AIR_DASH_DURATION = 0.3  # Duration of air dash in seconds
@export var AIR_DASH_VERTICAL = -200
@export var STOP_FACTOR = .1

var tap_count = 0
var is_running = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2
var original_collision_mask
var jump_up_buffer_time = 0.5
var jump_released_in_air = false
var jump_released_in_air_down = false
var jump_up_timer
var run_timer
var last_direction = 0
var last_tap_time = 0.0
var current_platform = null
var air_dash_timer = 0.0
var is_air_dashing = false
var air_dash_direction = Vector2.ZERO
var horizontal_speed = 0.0

@onready var board = get_parent().get_node("Board")
@onready var camera = $PlayerCamera
@onready var animated_sprite = $Sprite2D
@onready var interaction_area = $Area2D
@onready var player_area = $Area2D

func _ready():
	original_collision_mask = collision_mask

	jump_up_timer = Timer.new()
	jump_up_timer.one_shot = true
	jump_up_timer.wait_time = jump_up_buffer_time
	jump_up_timer.connect("timeout", Callable(self, "_on_jump_up_timeout"))
	add_child(jump_up_timer)
	
	run_timer = Timer.new()
	run_timer.one_shot = true
	run_timer.wait_time = DOUBLE_TAP_TIME
	run_timer.connect("timeout", Callable(self, "_on_run_timer_timeout"))
	add_child(run_timer)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

#region jumping up
	if Input.is_action_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		velocity.x = horizontal_speed
	#if velocity.y > 0:
	if Input.is_action_just_released("ui_up"):
		velocity.y += gravity * 30 * delta
		return  
	#if Input.is_action_pressed()
	if Input.is_action_just_pressed("ui_up") and not is_on_floor():
		jump_released_in_air = true
		jump_up_timer.start()
	if is_on_floor() and jump_released_in_air:
		velocity.y = JUMP_VELOCITY
		jump_released_in_air = false
		jump_up_timer.stop()
	if is_on_floor() and velocity.y > 0:
		velocity.y = -velocity.y * 0.5
	if is_on_floor():
		if animated_sprite.animation == "in_air":
			animated_sprite.play("idle")
#endregion
#region Jumping down
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		collision_mask &= ~1
		velocity.y = JUMP_VELOCITY / 10
		return  
	if Input.is_action_just_pressed("ui_down") and not is_on_floor():
		collision_mask &= ~1
		velocity.y = - JUMP_VELOCITY 
		#animate dash down
	if Input.is_action_just_released("ui_down"):
		collision_mask = original_collision_mask
#endregion
#region Chesspiece interaction
	if Input.is_action_just_pressed("ui_interact"):
		if player_area.selected_chess_piece:
			player_area.move_chess_piece(current_platform)
		elif player_area.nearby_chess_piece:
			player_area.select_chess_piece()
#endregion
#region directional movement (walk, run, dash)
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if (Input.is_action_just_pressed("ui_left") and direction < 0) or (Input.is_action_just_pressed("ui_right") and direction > 0):
			var current_time = Time.get_ticks_msec() / 1000.0
			if current_time - last_tap_time < DOUBLE_TAP_TIME and last_direction == direction:
				if is_on_floor():
					is_running = true
				else:
					start_air_dash(direction)
			else:
				is_running = false
			last_tap_time = current_time
			last_direction = direction

		if is_air_dashing:
			horizontal_speed = air_dash_direction.x * AIR_DASH_SPEED

		elif is_running:
			horizontal_speed = direction * RUN_SPEED
		else:
			horizontal_speed = direction * SPEED

		if is_on_floor():
			velocity.x = horizontal_speed
		else:
			velocity.x = lerp(velocity.x, horizontal_speed, AIR_CONTROL)

		if direction > 0:
			animated_sprite.scale.x = 1
		elif direction < 0:
			animated_sprite.scale.x = -1

		if is_on_floor():
			if is_running:	animated_sprite.play("run")
			else:	animated_sprite.play("walk")
	else:
		velocity.x *= STOP_FACTOR
		if is_on_floor() and abs(velocity.x) < 1 and (animated_sprite.animation == "walk" or animated_sprite.animation == "run" or animated_sprite.animation == "in_air"):
			animated_sprite.play("idle")
		is_running = false

	if not is_on_floor():
		animated_sprite.play("in_air")

	if is_air_dashing:
		air_dash_timer -= delta
		if air_dash_timer <= 0:
			end_air_dash()
#endregion

	move_and_slide()

	if Input.is_action_just_pressed("ui_interact"): 
		if current_platform:
			teleport()

func start_air_dash(direction):
	if not is_on_floor() and not is_air_dashing:
		is_air_dashing = true
		air_dash_timer = AIR_DASH_DURATION
		air_dash_direction = Vector2(direction, 0)
		velocity.y = AIR_DASH_VERTICAL
		#animation for dash 

func end_air_dash():
	is_air_dashing = false
	air_dash_direction = Vector2.ZERO

func _on_run_timer_timeout():
	tap_count = 0

func _on_jump_up_timeout():
	jump_released_in_air = false

func teleport():
	var target_field_name = current_platform.target_field_name
	if target_field_name != "":
		var target_field = board.get_node(target_field_name)
		if target_field:
			var central_platform = target_field.get_node("Platform0")
			if central_platform:
				global_position = central_platform.global_position
				update_camera_limits(central_platform.global_position)
				position += Vector2(0, -100)
				current_platform = central_platform

func update_camera_limits(center_position):
	camera.limit_left = center_position.x - 1000
	camera.limit_top = center_position.y - 500
	camera.limit_right = center_position.x + 1000
	camera.limit_bottom = center_position.y + 500

func _on_area_2d_body_entered(_body):
	pass # Replace with function body.
