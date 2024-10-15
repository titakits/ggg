extends Node2D

func _ready():
	# Connect the bottom teleport area signal only if not already connected
	var callable = Callable(self, "_on_BottomTeleportArea_body_entered")
	if not $BottomTeleportArea.is_connected("body_entered", callable):
		$BottomTeleportArea.connect("body_entered", callable)

func _on_BottomTeleportArea_body_entered(body):
	if body.name == "Player":
		var central_platform = $Platform0
		if central_platform:
			body.global_position = central_platform.global_position
			body.velocity = Vector2.ZERO 
