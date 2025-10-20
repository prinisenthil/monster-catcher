extends Control

signal pokemon_selected(index: int)

@onready var grid = $GridContainer

func populate_party():
	var party = GameData.player_party
	for child in grid.get_children():
		grid.remove_child(child)
	for i in range(party.size()):
		var poke = party[i]
		var btn = preload("res://scenes/ui/pokemon_menu_button.tscn").instantiate()
		btn.setup(poke, i)
		btn.pressed.connect(func(): emit_signal("pokemon_selected", i))
		grid.add_child(btn)
