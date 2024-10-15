extends Node2D

# References to the player's camera and the board camera
@onready var player_camera = $Player/PlayerCamera
@onready var board_camera = $Board/BoardCamera

# Boolean to track the current camera state
var using_board_camera = false
# Input action for toggling the camera
const TOGGLE_CAMERA_KEY = "toggle_camera"

func _ready():
	# Ensure the player's camera is the default
	player_camera.make_current()

func _process(_delta):
	if Input.is_action_just_pressed(TOGGLE_CAMERA_KEY):
		toggle_camera() 

func toggle_camera():
	using_board_camera = !using_board_camera
	if using_board_camera:
		board_camera.make_current()	
	else:
		player_camera.make_current()
