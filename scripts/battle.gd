extends Node2D

# References to the Pokémon nodes and related state
var trainer_pokemon
var trainer_pokemon_anim
var enemy_pokemon
var keep_playing = true
var end_battle = false
var trainer_move = false

# Get player button references
@onready var player_buttons = $BattleControl/BattleBtnContainer
@onready var attack_btn = $BattleControl/BattleBtnContainer/AttackBtn
@onready var flee_btn = $BattleControl/BattleBtnContainer/FleeBtn
@onready var capture_btn = $BattleControl/BattleBtnContainer/CaptureBtn
@onready var pokemon_btn = $BattleControl/BattleBtnContainer/PokemonBtn

var pokemon_cancel_btn
var attack_cancel_btn
@onready var poke_menu = $PokemonMenu
@onready var attack_menu = $AttackMenu

# Custom signals
signal textbox_closed
signal attack_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$EnemyPokemon.modulate.a = 0.0  # Make fully transparent
	$EnemyControl.modulate.a = 0.0

	# Hide initial UI and animation elements
	$BattleTrainer/Pokeball.visible = false
	$BattleTrainer/PokeballOpening.visible = false
	$Textbox.hide()
	$TrainerPokemon.visible = false
	$PlayerControl.hide()

	# Load player and enemy Pokémon
	var pokemon_ref = GameData.player_party[0]
	$TrainerPokemon.load_pokemon(pokemon_ref, true)
	$EnemyPokemon.load_from_resource(Global.chosen_mon, Global.mon_level, false)

	var tween = create_tween()
	tween.parallel().tween_property($EnemyPokemon, "modulate:a", 1.0, 0.2)  # Fade in over 0.2s
	tween.parallel().tween_property($EnemyControl, "modulate:a", 1.0, 0.2)
	$EnemyPokemon.visible = true
	$EnemyControl.visible = true

	# Store references
	trainer_pokemon = $TrainerPokemon
	enemy_pokemon = $EnemyPokemon

	# Initialize enemy health
	set_enemy_health(enemy_pokemon)

	# Set UI: name, exp, level
	set_ui(true) # set player ui
	set_ui(false) # set enemy ui

	# Connect button presses to respective functions
	attack_btn.pressed.connect(self._AttackBtn_pressed)
	flee_btn.pressed.connect(self._FleeBtn_pressed)
	capture_btn.pressed.connect(self._CaptureBtn_pressed)
	pokemon_btn.pressed.connect(self._PokemonBtn_pressed)

	# Begin battle introduction
	display_text("A wild %s appeared!" % enemy_pokemon.poke_name.to_upper())
	await get_tree().create_timer(1.3).timeout
	await self.textbox_closed

	# Animate trainer throwing the Pokéball
	trainer_play()
	display_text("What will %s do?" % trainer_pokemon.poke_name)
	await get_tree().create_timer(1).timeout
	Fade("in", 0.3, $BattleControl/BattleBtnContainer)
	trainer_move = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	battle()
	update_health(trainer_pokemon)
	update_health(enemy_pokemon)

# Function to display battle dialogue
func display_text(text):
	$Textbox.show()
	await $Textbox/Label.type_text(text)
	if get_tree():
		await get_tree().create_timer(0.3).timeout

# Closes textbox when input is pressed
func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		emit_signal("textbox_closed")

# Controls visibility of the player's move buttons
func battle():
	if not trainer_move:
		player_buttons.hide()
	else:
		player_buttons.show()

# Animates trainer throwing Pokéball and reveals Pokémon
func trainer_play():
	$BattleTrainer/Trainer.play("TrainerThrow")
	$BattleTrainer/PokeballMove.play("ThrowPokeball")
	await get_tree().create_timer(1).timeout
	$BattleTrainer/PokeballOpening.visible = true
	$BattleTrainer/PokeballOpening.play("open")
	trainer_pokemon.visible = true
	$PlayerControl.show()
	#player_buttons.show()

# Sets player and enemy UI
func set_ui(player: bool):
	# Set UI: name, exp, level
	if player:
		$PlayerControl/Name.text = $TrainerPokemon.poke_name
		$PlayerControl/ExpBar.value = trainer_pokemon.exp
		$PlayerControl/Level.text = "%d" % trainer_pokemon.level
	else:
		$EnemyControl/Name.text = $EnemyPokemon.poke_name
		$EnemyControl/Level.text = "%d" % enemy_pokemon.level

# Called when player presses "Attack"
func _AttackBtn_pressed():
	trainer_move = false
	player_buttons.visible = false
	attack_menu.visible = true
	attack_menu.populate_moves()
	attack_menu.move_selected.connect(self._on_move_selected)
	attack_cancel_btn = $AttackMenu/CancelBtn
	attack_cancel_btn.pressed.connect(self._AttackCancelBtn_pressed)

# When a party pokemon is selected
func _on_move_selected(index: int):
	attack_menu.visible = false
	var selected_move = GameData.player_party[0].pokemon_data.moves[index]

	# Player attacks enemy
	attack(trainer_pokemon, enemy_pokemon, selected_move)
	await self.attack_over
	
	# Enemy attacks player
	var move_list = enemy_pokemon.pokemon_data.moves
	var enemy_move = move_list[randi() % move_list.size()]
	attack(enemy_pokemon, trainer_pokemon, enemy_move)
	await self.attack_over

	# Prompt next action
	display_text("What will %s do?" % trainer_pokemon.poke_name)
	await get_tree().create_timer(1).timeout
	trainer_move = true

# Called when player presses cancel in Attack menu
func _AttackCancelBtn_pressed():
	attack_menu.visible = false
	trainer_move = true

# Called when player presses "Flee"
func _FleeBtn_pressed():
	trainer_move = false
	display_text("Got away safely!")
	await get_tree().create_timer(1).timeout
	await self.textbox_closed
	GameData.player_party[0].set_stats(trainer_pokemon.health, trainer_pokemon.exp, trainer_pokemon.level)
	Global.change_scene("world")
	Global.world = "world"

# Called when player presses "Capture"
func _CaptureBtn_pressed():
	Fade("out", 0.7, $BattleControl, enemy_pokemon) # stop showing battle buttons and enemy pokemon
	display_text("Captured %s!" % enemy_pokemon.poke_name)
	await get_tree().create_timer(1).timeout
	await self.textbox_closed
	# Capture pokemon and add to player party
	GameData.capture(enemy_pokemon, "")
	GameData.player_party[0].set_stats(trainer_pokemon.health, trainer_pokemon.exp, trainer_pokemon.level)
	Global.change_scene("world")
	Global.world = "world"

# Called when player presses "Pokemon"
func _PokemonBtn_pressed():
	trainer_move = false
	Fade("in", 0.3, poke_menu)
	GameData.player_party[0].set_stats(trainer_pokemon.health, trainer_pokemon.exp, trainer_pokemon.level)
	poke_menu.populate_party()
	poke_menu.pokemon_selected.connect(self._on_party_pokemon_selected)
	pokemon_cancel_btn = $PokemonMenu/CancelBtn
	pokemon_cancel_btn.pressed.connect(self._PokemonCancelBtn_pressed)

# When a party pokemon is selected
func _on_party_pokemon_selected(index: int):
	var selected = GameData.player_party[index]
	if selected.current_health <= 0:
		display_text("That Pokémon has fainted!")  # optional fallback
		await get_tree().create_timer(1).timeout
		return
	if index == 0:
		_PokemonCancelBtn_pressed()
		return

	# Replace the active Pokémon
	trainer_pokemon.load_pokemon(selected, true)
	GameData.swap(index)

	# reset ui for new pokemon
	set_ui(true)

	Fade("out", 0.3, poke_menu)

	display_text("Go, %s!" % selected.nickname)
	await get_tree().create_timer(1).timeout
	trainer_move = true
	await self.textbox_closed

# Called when player presses cancel in Pokemon menu
func _PokemonCancelBtn_pressed():
	trainer_move = true
	Fade("out", 0.3, poke_menu)

func Fade(str: String, secs: float, obj, obj2 = null):
	match str:
		"in":
			obj.modulate.a = 0.0
			var new_tween = create_tween()
			new_tween.tween_property(obj, "modulate:a", 1.0, secs)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_OUT)
			obj.visible = true
		"out":
			if obj2:
				var new_tween = create_tween()
				new_tween.parallel().tween_property(obj, "modulate:a", 0.0, secs)\
					.set_trans(Tween.TRANS_SINE)\
					.set_ease(Tween.EASE_IN)
				new_tween.parallel().tween_property(obj2, "modulate:a", 0.0, secs)\
					.set_trans(Tween.TRANS_SINE)\
					.set_ease(Tween.EASE_IN)
				await new_tween.finished
				obj.visible = false
				obj2.visible = false
			else:
				var new_tween = create_tween()
				new_tween.tween_property(obj, "modulate:a", 0.0, secs)\
					.set_trans(Tween.TRANS_SINE)\
					.set_ease(Tween.EASE_IN)
				await new_tween.finished
				obj.visible = false

# Handles the attack logic
func attack(pokemon, target_pokemon, move: PokemonMove):
	display_text("%s used %s!" % [pokemon.poke_name.to_upper(), move.name])
	if get_tree(): await get_tree().create_timer(1).timeout
	await self.textbox_closed

	# Play attack animation
	if pokemon == trainer_pokemon:
		$AttackAnim.play("PlayerAttack")
	else:
		$AttackAnim.play("EnemyAttack")
	await get_tree().create_timer(0.3).timeout

	# Calculate damage and apply to target
	var dmg = calc_stat(pokemon, target_pokemon, move.power)
	target_pokemon.health = max(target_pokemon.health - dmg, 0)

	# Show damage dealt
	await get_tree().create_timer(0.5).timeout
	display_text("%s dealt %d damage!" % [pokemon.poke_name.to_upper(), dmg])
	await get_tree().create_timer(1).timeout
	await self.textbox_closed

	# If target faints
	if target_pokemon.health <= 0:
		target_pokemon.health = 0
		await get_tree().create_timer(0.5).timeout
		target_pokemon.visible = false
		display_text("%s fainted!" % target_pokemon.poke_name)
		await get_tree().create_timer(1).timeout
		await self.textbox_closed

		# Give EXP if enemy fainted
		if pokemon == trainer_pokemon:
			var exp_gained = calc_exp(enemy_pokemon.pokemon_data.base_exp, pokemon.level, enemy_pokemon.level)
			display_text("%s gained %d exp" % [pokemon.poke_name, exp_gained])
			await get_tree().create_timer(1).timeout
			await update_exp(pokemon, exp_gained)
			await self.textbox_closed

		# Save current stats to GameData
		GameData.player_party[0].set_stats(trainer_pokemon.health, trainer_pokemon.exp, trainer_pokemon.level)

		# Return to world or pokecenter scene
		if pokemon == enemy_pokemon: # player fainted
			GameData.available_pokemon -= 1
			if GameData.available_pokemon == 0:
				Global.out_of_pokemon = true
				display_text("Player is out of pokemon!")
				await get_tree().create_timer(1).timeout
				await self.textbox_closed
				Global.pos_x = 488
				Global.pos_y = 166
				Global.change_scene("pokecenter")
				Global.world = "pokecenter"

		else:
			Global.change_scene("world")
			Global.world = "world"

	# Signal that attack turn is over
	emit_signal("attack_over")

# Simple Pokémon damage formula
func calc_stat(pokemon, enemy, power):
	var dmg = (2*pokemon.level/5) + 2
	dmg *= power
	dmg *= (pokemon.attack/enemy.defense)
	dmg /= 50
	dmg += 2
	return round(dmg)

func calculate_damage(attacker, defender, power, move_type: String, is_critical := false) -> int:
	var level = attacker.level
	var attack = attacker.attack
	var defense = defender.defense

	# Base damage
	var dmg = (((2 * level / 5 + 2) * power * (attack / defense)) / 50) + 2

	# Modifiers
	var modifier = 1.0

	# STAB (Same Type Attack Bonus)
	if move_type == attacker.element:
		modifier *= 1.5

	# Random factor (between 0.85 and 1.0)
	modifier *= randf_range(0.85, 1.0)

	# Critical hit
	if is_critical:
		modifier *= 1.5

	# Type effectiveness (optional: check type chart here)
	# Example: if defender.element == "Water" and move_type == "Grass":
	#     modifier *= 2.0

	return round(dmg * modifier)


# Sets initial enemy health bar value
func set_enemy_health(enemy_poke):
	var enemy_health_bar = $EnemyControl/HealthBar
	enemy_health_bar.max_value = enemy_poke.max_health
	enemy_health_bar.value = enemy_poke.max_health

# Updates the health bar of a Pokémon
func update_health(pokemon):
	var health_bar
	var control
	if pokemon == trainer_pokemon:
		health_bar = $PlayerControl/HealthBar
		control = $PlayerControl
	else:
		health_bar = $EnemyControl/HealthBar
		control = $EnemyControl
	if pokemon.health <= 0:
		pokemon.health = 0
	health_bar.max_value = pokemon.max_health

	# Animate health bar change
	var tween = create_tween()
	tween.tween_property(health_bar, "value", pokemon.health, 0.3).set_trans(Tween.TRANS_LINEAR)
	control.get_node("HealthProgress").text = "%d/%d" % [pokemon.health, pokemon.max_health]

func update_exp(pokemon, val):
	var exp_bar = $PlayerControl/ExpBar
	pokemon.exp += val

	while pokemon.exp >= pokemon.max_exp:
		# Fill bar to max
		var tween = create_tween()
		tween.tween_property(exp_bar, "value", pokemon.max_exp, 0.5).set_trans(Tween.TRANS_LINEAR)
		#exp_bar.get_node("Progress").text = "%d/%d" % [pokemon.exp, pokemon.max_exp]
		await get_tree().create_timer(0.3).timeout

		# Level up
		pokemon.exp -= pokemon.max_exp

		await get_tree().create_timer(0.3).timeout
		pokemon.level_up()
		display_text("%s grew to level %d!" % [pokemon.poke_name, pokemon.level])
		$PlayerControl/Level.text = "%d" % pokemon.level
		await get_tree().create_timer(1).timeout
		await self.textbox_closed

		# Reset EXP bar
		exp_bar.value = 0
		#exp_bar.get_node("Progress").text = "%d/%d" % [0, pokemon.max_exp]

	# Fill bar to leftover EXP (if any)
	var final_exp = min(pokemon.exp, pokemon.max_exp)
	var tween = create_tween()
	tween.tween_property(exp_bar, "value", final_exp, 0.5).set_trans(Tween.TRANS_LINEAR)
	#exp_bar.get_node("Progress").text = "%d/%d" % [final_exp, pokemon.max_exp]
	await get_tree().create_timer(0.3).timeout

func calc_exp(base_exp: int, player_lvl: int, enemy_lvl: int):
	var numerator = base_exp * enemy_lvl * (2 * enemy_lvl + 10)
	var denominator = enemy_lvl + player_lvl + 10
	var exp = numerator / denominator
	return int(exp) + 1  # Ensure at least 1 EXP is gained
