extends Area2D		# This script is attached to a door area used to detect player entry

# Reference to the door's Area2D
@onready var door_area = self

# Timer node used to control when the door reactivates
@onready var timer = $Timer

# Called when the scene starts
func _ready() -> void:
	# Disable the door collision/monitoring when the scene first loads
	door_area.set_deferred("monitoring", false)
	# Start the timer to re-enable the door collision after a short delay
	timer.start()

# Called when body enters door Area2D
func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		# Set global flag to track that a scene transition from the Pokécenter is in progress
		Global.changing_pokecenter = true

# Called when the door reactivation timer ends
func _on_timer_timeout() -> void:
	# Re-enable the door monitoring after the player has moved away
	door_area.monitoring = true
