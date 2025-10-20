extends Node2D

# References to child nodes (set in _ready)
var trainer 			# The trainer AnimatedSprite2D node
var open 				# The PokéballOpening AnimatedSprite2D node
var anim_player 		# The PokéballMove AnimationPlayer node

# Control flag to prevent repeated playback of animations
var keep_playing = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Cache references to important child nodes
	trainer = $Trainer
	open = $PokeballOpening
	anim_player = $PokeballMove


# Called every frame. 'delta' is the elapsed time since the previous frame. Not currently being used.
func _process(delta: float) -> void:
	# Can optionally trigger battle animations here
	#battle()
	pass

# Starts the battle animation sequence if Global.battling is set
func battle():
	if Global.battling:
		Global.battling = false			# Reset the global flag to avoid retriggering
		trainer.play("TrainerThrow")		# Play trainer throw animation
		anim_player.play("ThrowPokeball")	# Play Pokéball throw animation
		$BattleAnimation.start()			# Start a Timer node to delay next step

# Triggered when BattleAnimation Timer times out
# Stops trainer animation and starts opening the ball
func _on_battle_animation_timeout() -> void:
	trainer.stop()
	$BallOpen.start() # Start next Timer to open Pokéball

# Triggered when BallOpen Timer times out
# Makes the Pokéball open visible and plays opening animation
func _on_ball_open_timeout() -> void:
	if keep_playing:
		keep_playing = false		# Prevent this from playing multiple times
		open.visible = true			# Show the Pokéball opening animation node
		open.play()					# Play the Pokéball opening animation
		$CloseBall.start()			# Start next Timer to close the ball

# Triggered when CloseBall Timer times out
# Hides the Pokéball opening animation and stops it
func _on_close_ball_timeout() -> void:
	open.stop()				# Stop the animation
	open.visible = false	# Hide the sprite
