extends Control

signal move_selected(index: int)

@onready var grid = $GridContainer

func populate_moves():
	var moves = GameData.player_party[0].pokemon_data.moves
	for child in grid.get_children():
		grid.remove_child(child)
	for i in range(moves.size()):
		var move = moves[i]
		var btn = preload("res://scenes/ui/attack_menu_button.tscn").instantiate()
		btn.setup(move)
		btn.pressed.connect(func(): emit_signal("move_selected", i))
		grid.add_child(btn)
