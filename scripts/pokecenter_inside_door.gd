extends Area2D	# The door is an Area2D node that detects overlap with the player

# References
@onready var door_area = self  # Reference to the door's Area2D
@onready var timer = $Timer       # Timer node to control the delay

# Called when scene starts
func _ready() -> void:
	# Disable the door collision/monitoring when the scene first loads
	door_area.set_deferred("monitoring", false)
	# Start the timer to re-enable the door collision after a short delay
	timer.start()

# Triggered when the player walks into the door area (after timer is done)
func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		# Request transition back to the overworld scene
		Global.change_scene("world")

		# Update global tracking for scene state
		Global.world = "world"					# Current world after change
		Global.prev_world = "pokecenter"		# Track pokecenter as previous world

# Called when the door reactivation timer ends
func _on_timer_timeout() -> void:
	# Re-enable the door collision after the player has moved away
	door_area.monitoring = true
