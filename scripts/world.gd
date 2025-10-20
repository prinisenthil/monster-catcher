extends Node2D		# Main script for the overworld scene

# Flag to determine if the player is "walking in" after returning from another scene
var entering = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add starter Pokémon only on the first load
	if Global.first_spawn:
		# Add Squirtle to party with nickname "squirt", 16 HP, level 5
		GameData.add_to_party(preload("res://pokemon resources/gaffy.tres"), "", 16, 5)
		Global.first_spawn = false

	# Store player reference globally so other scenes/scripts can access it
	var player = $player
	Global.player = player

	# Set player position from saved global coordinates
	player.position.x = Global.pos_x
	player.position.y = Global.pos_y
	set_dir(Global.spawn_dir)

	# If the player just exited the Pokécenter, start auto-walk in
	if (Global.prev_world == "pokecenter"):
		entering = true
		$player.auto_walk(Vector2.DOWN, 1)
		#$player.battle_playing = true	# Disable movement input
		#$EnterWalk.start()				# Start timed auto-walk animation

# Called every frame
func _process(delta: float) -> void:
	change_scene()		# Check and trigger any pending scene changes
	#if entering:
		#walk()			# Animate the player walking into the world

func set_dir(dir: String):
	var anim = $player/AnimatedSprite2D
	match dir:
		"up":
			anim.play("back_idle")
		"down":
			anim.play("front_idle")
		"right":
			anim.play("right_idle")
		"left":
			anim.play("left_idle")

# Moves the player downward automatically as part of entry animation
func walk():
	if entering:
		$player/AnimatedSprite2D.play("front_walk")
		$player.velocity.x = 0
		$player.velocity.y = 40
		$player.move_and_slide()

# Called when EnterWalk timer finishes
func _on_enter_walk_timeout() -> void:
	entering = false			# Stop auto-walk logic
	$player.velocity.y = 0		# Stop movement
	$player/AnimatedSprite2D.play("front_idle") # Idle animation
	$player/AnimatedSprite2D.stop()
	$WalkAgain.start()			# Start second timer to allow player control again

# Called when WalkAgain timer finishes
func _on_walk_again_timeout() -> void:
	$player.battle_playing = false # Re-enable manual player control

# Handles transitions between world, Pokécenter, and battle scenes
func change_scene():
	# Update global position to remember player’s current coordinates
	Global.pos_x = $player.position.x
	Global.pos_y = $player.position.y

	# Transition to Pokécenter if flagged
	if Global.changing_pokecenter:
		Global.changing_pokecenter = false
		Global.prev_world = "world"
		Global.change_scene("pokecenter")
		Global.world = "pokecenter"
		Global.pos_x = 488
		Global.pos_y = 166 # Spawn position inside Pokécenter

	# Transition to battle scene if flagged
	if Global.changing_battle:
		load_enemy()
		Global.changing_battle = false
		Global.prev_world = "world"
		Global.change_scene("battle")
		Global.world = "battle"

func load_enemy():
	var min_lvl = Global.encounter_zone.min_level
	var max_lvl = Global.encounter_zone.max_level
	var encounter_list = Global.encounter_zone.pokemon_array
	Global.chosen_mon = encounter_list[randi() % encounter_list.size()]
	Global.mon_level = randi_range(min_lvl, max_lvl)
