extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -800.0
const RUN_SPEED = 600.0
const DOUBLE_TAP_TIME = 0.25
const AIR_CONTROL = 0.5  # Factor for air control (0.0 to 1.0)
const AIR_DASH_SPEED = 1600.0  # Speed for air dash
const AIR_DASH_DURATION = 0.3  # Duration of air dash in seconds
const STOP_FACTOR = .5

var tap_count = 0
var is_running = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2
var original_collision_mask
var jump_buffer_timer = 0.2
var jump_up_buffer_time = 0.2
var jump_released_in_air = false
var jump_down_timer
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
	
	jump_down_timer = Timer.new()
	jump_down_timer.one_shot = true
	jump_down_timer.wait_time = jump_buffer_timer
	jump_down_timer.connect("timeout", Callable(self, "_on_jump_down_timeout"))
	add_child(jump_down_timer)

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
	var was_on_floor = is_on_floor()
	
	if not is_on_floor():
		if velocity.y > 0:  
			velocity.y += gravity * 3 * delta
		else:  
			velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and Input.is_action_pressed("ui_down") and is_on_floor():
		jump_down_through_platform()
		return  

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		velocity.x = horizontal_speed
		return  

	if Input.is_action_just_pressed("ui_accept") and not is_on_floor():
		jump_released_in_air = true
		jump_up_timer.start()

	if is_on_floor() and jump_released_in_air:
		velocity.y = JUMP_VELOCITY
		jump_released_in_air = false
		jump_up_timer.stop()

	if is_on_floor():
		if animated_sprite.animation == "in_air":
			animated_sprite.play("idle")

	if Input.is_action_just_pressed("ui_interact"):
		if player_area.selected_chess_piece:
			player_area.move_chess_piece(current_platform)
		elif player_area.nearby_chess_piece:
			player_area.select_chess_piece()

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
			if is_running:
				animated_sprite.play("run")
			else:
				animated_sprite.play("walk")
				
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

	move_and_slide()

	if not was_on_floor and is_on_floor():
		horizontal_speed = velocity.x 
		

	if Input.is_action_just_released("ui_accept"):
		if jump_down_timer.is_stopped():
			jump_down_timer.start()
		else:
			jump_released_in_air = false

	if Input.is_action_just_pressed("teleport"):
		if current_platform:
			teleport()

func start_air_dash(direction):
	if not is_on_floor() and not is_air_dashing:
		is_air_dashing = true
		air_dash_timer = AIR_DASH_DURATION
		air_dash_direction = Vector2(direction, 0)
		velocity.y = 0  

func end_air_dash():
	is_air_dashing = false
	air_dash_direction = Vector2.ZERO
	

func _on_run_timer_timeout():
	tap_count = 0

func jump_down_through_platform():
	collision_mask &= ~1
	velocity.y = JUMP_VELOCITY / 3

func _on_jump_down_timeout():
	reset_collision()

func _on_jump_up_timeout():
	jump_released_in_air = false

func reset_collision():
	collision_mask = original_collision_mask

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
