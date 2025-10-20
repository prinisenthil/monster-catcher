extends Node2D

# Flag to indicate the player is entering the Pokécenter (used to control auto-walk)
var entering = false

# Called when the Pokécenter scene loads
func _ready() -> void:
	Global.player = $player
	if Global.out_of_pokemon:
		Global.out_of_pokemon = false
		$player.position.x = Global.pokecenter_x
		$player.position.y = Global.pokecenter_y
		$player/AnimatedSprite2D.play("back_idle")
		$Nurse.start_conversation(true)
	else:
		entering = true		# Start the scene in 'entering' mode
		#$player.can_move = false	# Freeze player manual movement during entry walk
		#$EnterWalk.start()	# Start a timer to end the entry walk automatically

# Called every frame
func _process(delta: float) -> void:
	# While entering, control the player's automatic movement
	if entering:
		walk()

# Controls the auto-walk upward animation
func walk():
	if entering:
		# walk five steps upward into the building
		print($player.position.x)
		print($player.position.y)
		$player.auto_walk(Vector2.UP, 1)
		entering = false
		# Play "walking upward" animation
		#$player/AnimatedSprite2D.play("up_walk")

		# Move the player upward slowly (simulates walking into the Pokécenter)
		#$player.velocity.x = 0
		#$player.velocity.y = -40

		# Apply the movement
		#$player.move_and_slide()

# Called when the EnterWalk timer finishes (after entry animation ends)
func _on_enter_walk_timeout() -> void:
	entering = false				# Stop auto-walk
	$player.velocity.y = 0			# Stop vertical movement
	$player/AnimatedSprite2D.play("up_idle")		# Show idle frame
	$player/AnimatedSprite2D.stop()					# Stop animation
	$WalkAgain.start()				# Start a delay before re-enabling full control

# Called when the WalkAgain timer ends (allows player to move again)
func _on_walk_again_timeout() -> void:
	$player.can_move = true	# Re-enable manual movement
