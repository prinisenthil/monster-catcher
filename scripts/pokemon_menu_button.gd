extends Button
class_name PokemonMenuButton

@export var fainted: bool

func setup(pokemon: PartyPokemon, party_index: int):
	var data = pokemon.pokemon_data
	$Sprite.texture = data.menu_sprite
	$Name.text = pokemon.nickname
	$Lvl.text = "Lv. %d" % pokemon.level
	$HealthBar.max_value = pokemon.get_max_health()
	$HealthBar.value = pokemon.current_health
	fainted = pokemon.current_health <= 0
