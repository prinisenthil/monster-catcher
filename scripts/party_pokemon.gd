extends Resource
class_name PartyPokemon # Allows this to be used and created in the editor as a custom type

# 🎮 Instance-specific data for a Pokémon in the player's party

@export var pokemon_data: PokemonResource		# The base stats, sprite, type, and other species info
@export var nickname: String = ""				# Optional nickname for personalization
@export var level: int = 5						# The Pokémon's current level
@export var exp: int = 0						# Current experience points toward next level
@export var current_health: int = 10			# Current HP, used in battle and healing logic
@export var status_condition: String = ""		# e.g. "Poisoned", "Paralyzed", "" (none)

# 🧠 Calculates the Pokémon's max HP based on level and base stats
func get_max_health() -> int:
	var IV = 15		# Individual Value: pseudo-random hidden stat between 0–31 (simplified here)
	var EV = 0		# Effort Value: gained through training, also simplified to 0
	return ((2 * pokemon_data.base_health + IV + (EV / 4)) * level / 100) + level + 10

# 📦 Set multiple stats at once, usually after a battle or loading from save
func set_stats(new_health, new_exp, new_level):
	current_health = new_health
	exp = new_exp
	level = new_level
