extends CharacterBody2D  # Represents a Pokémon entity in the battle scene

# Reference to the Pokémon's species template (stats, sprites, etc.)
@export var pokemon_data: PokemonResource

# Base constants
const max_level = 100
const base_health = 10	# Used for fallback or initial HP calc

# pokemon name or player given nickname
var poke_name = ""

# Battle and growth-related stats
@export var speed = 100
@export var max_health = 16
@export var health = 16
@export var accuracy = 100
@export var base_attack = 10
@export var base_defense = 10
@export var base_sp_attack = 10
@export var base_sp_defense = 10
@export var level = 5 # Starting level

# Calculated stats based on level and base values
var attack: int
var defense: int
var sp_attack: int
var sp_defense: int

# EXP stat and progress
var max_exp = 100
var exp = 0

# UI references (ProgressBars)
var health_bar
var exp_bar

# State flags
var player_pokemon = false		# True if this Pokémon belongs to the player
var fainted = false				# True if health reaches 0

# Called when scene enters scene tree
func _ready():
	pass

# Called every physics frame
func _physics_process(delta: float) -> void:
	if not fainted:
		battle_end()

# Loads static Pokémon data from a PokemonResource (.tres file)
# 'player' bool variable determines whether to show front or back sprite in battle
func load_from_resource(data: PokemonResource, custom_level: int, player: bool):
	pokemon_data = data
	poke_name = data.name
	speed = data.speed
	accuracy = data.accuracy
	base_attack = data.base_attack
	base_defense = data.base_defense
	base_sp_attack = data.base_sp_attack
	base_sp_defense = data.base_sp_defense
	level = custom_level

	set_stats()		# Calculate derived stats (attack, defense, etc.)
	max_health = calc_hp()
	health = max_health

	# Set correct sprite (front for enemy, back for player)
	if player:
		$Sprite.texture = data.back_sprite
	else:
		$Sprite.texture = data.front_sprite

# Loads a live PartyPokemon instance (player-owned Pokémon)
# Copies nickname, EXP, and health from instance
func load_pokemon(pokemon: PartyPokemon, player: bool):
	load_from_resource(pokemon.pokemon_data, pokemon.level, player)
	poke_name = pokemon.nickname
	exp = pokemon.exp
	level = pokemon.level
	set_stats()
	health = pokemon.current_health

# Handles level-up: increases level and recalculates stats
func level_up():
	level += 1
	var old_health = max_health
	set_stats()
	var add_health = max_health - old_health
	health += add_health

# Recalculates all derived stats based on level and base stats
func set_stats():
	attack = calc_stat(base_attack)
	defense = calc_stat(base_defense)
	sp_attack = calc_stat(base_sp_attack)
	sp_defense = calc_stat(base_sp_defense)
	max_health = calc_hp()

# Calculates a stat like attack or defense using base stat, IV, EV
func calc_stat(base_stat: int, iv := 15, ev := 0) -> int:
	var stat = ((2 * base_stat + iv + int(ev / 4)) * level / 100.0) + 5
	return int(stat)

# Calculates the Pokémon's maximum HP using standard formula
func calc_hp():
	var IV = 15
	var EV = 0
	var HP = ((2 * base_health + IV + (EV / 4)) * level / 100) + level + 10
	return HP

# Updates health bar UI to reflect current health
func update_health():
	health_bar = $HealthBar
	health_bar.max_value = max_health
	health_bar.value = health

	# Set health to 0 if below
	if health <= 0:
		health = 0

	# Animate health bar smoothly
	var tween = create_tween()
	tween.tween_property(health_bar, "value", health, 0.5).set_trans(Tween.TRANS_LINEAR)

	# Show numerical HP (e.g. "15/30")
	health_bar.get_node("Progress").text = "%d/%d" % [health, max_health]

# Check if Pokémon has fainted
func battle_end():
	if health == 0:
		fainted = true
