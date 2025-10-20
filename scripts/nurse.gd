extends AnimatedSprite2D # Nurse character node with animation support

# Cached reference to the dialogue UI box
@onready var dialogue_label = $UI/Textbox

# Flag to track whether the player is within interaction range
var can_interact = false

# Signal emitted when the player closes the dialogue textbox
signal textbox_closed

# Called when the scene is first loaded
func _ready() -> void:
	# Start with dialogue hidden
	dialogue_label.visible = false


# Called every frame
func _process(delta: float) -> void:
	# If player is within range and presses the interact key (e.g. "E"), start conversation
	# Can customize the key in the Input Map
	if can_interact and Input.is_action_just_pressed("interact"):
		start_conversation(false)

# Starts the nurse conversation and healing sequence
func start_conversation(fainted: bool):
	Global.out_of_pokemon = false
	GameData.available_pokemon = GameData.player_party.size()
	# Stop player movement during conversation
	Global.player.can_move = false
	if not fainted:
		# Show the textbox and greet the player
		dialogue_label.visible = true
		display_text("Hello! Welcome to the Pokécenter. One moment while I heal your Pokémon.")
		await get_tree().create_timer(1).timeout
		await self.textbox_closed

	# Call global function to fully heal all Pokémon in the player's party
	GameData.heal_pokemon()

	# Show confirmation message
	display_text("Thank you for waiting. We have healed all of your pokemon. Have a nice day!")
	Global.player.can_move = true

# Handles input to close the textbox (e.g. Enter or left click)
func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		$UI/Textbox.hide()
		emit_signal("textbox_closed")

# Displays text in the dialogue box
func display_texting(text):
	$UI/Textbox.show()
	await $UI/Textbox/Dialogue.type_text(text)

func display_text(text):
	$UI/Textbox.show()
	type_text(text)

# Called when the player enters the interaction zone around the nurse
func _on_interaction_zone_body_entered(body: Node2D) -> void:
	if body.name == "player":
		can_interact = true # Enable interaction

# Called when the player leaves the interaction zone
func _on_interaction_zone_body_exited(body: Node2D) -> void:
	if body.name == "player":
		can_interact = false # Disable interaction
		dialogue_label.visible = false  # Hide any open dialogue

func type_text(text):
	var label = $UI/Textbox/Dialogue
	label.text = ""
	for i in range(text.length()):
		label.text += text[i]
		await get_tree().create_timer(0.03).timeout
		if Input.is_action_just_pressed("ui_accept"):
			label.text = text
			await get_tree().create_timer(1).timeout
			break
	await get_tree().create_timer(0.5).timeout
