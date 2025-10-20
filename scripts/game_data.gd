extends Node

# Global Game Data Script — Autoloaded in Project Settings

# Holds the player's current team of Pokémon as an array of PartyPokemon instances
var player_party: Array[PartyPokemon] = []
var available_pokemon = 1

# Adds a new Pokémon to the player's party
func add_to_party(resource: PokemonResource, nickname, health, level):
	# Create a new instance of PartyPokemon (individual Pokémon owned by the player)
	var new_pokemon = PartyPokemon.new()

	# Set nickname and assign the species data (PokemonResource)
	if nickname == "":
		nickname = resource.name
	new_pokemon.nickname = nickname
	new_pokemon.pokemon_data = resource

	# Set level, starting EXP, and health
	new_pokemon.level = level
	new_pokemon.exp = 0
	new_pokemon.current_health = health

	# Add this Pokémon to the party array
	player_party.append(new_pokemon)

# Fully heals all Pokémon in the player's party
func heal_pokemon():
	for mon in player_party:
		# Set each Pokémon's current health to its max health (calculated from level/base stats)
		mon.current_health = mon.get_max_health()

func capture(pokemon, nickname):
	# Retrieve pokemon data + current health and level from pokemon
	var pokemon_data = pokemon.pokemon_data
	var health = pokemon.health
	var level = pokemon.level

	# Add pokemon to player party
	add_to_party(pokemon_data, nickname, health, level)

func swap(index: int):
	var temp = player_party[0]
	player_party[0] = player_party[index]
	player_party[index] = temp
