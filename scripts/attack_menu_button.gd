extends Button
class_name AttackMenuButton


func setup(move: PokemonMove):
	$Label.text = move.name.to_upper()
	set_color(move)

func set_color(move: PokemonMove):
	var stylebox = self.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	var stylebox_hover = self.get_theme_stylebox("hover").duplicate() as StyleBoxFlat
	var color = "#8c8c8c"
	var border = ""
	var hover_color = "#d4d2c9"
	var hover_border = ""
	match move.type:
		"Grass":
			color = "#39bf50"
			border = "#288538"
			hover_color = "#91eb8a"
			hover_border = "#7dc977"
		"Fire":
			color = "#cc8143"
			border = "#a86a38"
			hover_color = "#ebaf8a"
			hover_border = "#c49374"
		"Air":
			color = "#c0a4f5"
			border = "#9d85c9"
			hover_color = "#d6c3fa"
			hover_border = "#b1a1cf"
		"Water":
			color = "#6997db"
			border = "#5980ba"
			hover_color = "#a4bbf5"
			hover_border = "#8ea2d4"
		"Normal":
			color = "#8c8c8c"
			border = "#696868"
			hover_color = "#d4d2c9"
			hover_border = "#b3b1a8"

	stylebox.bg_color = color
	stylebox.border_color = border
	stylebox_hover.bg_color = hover_color
	stylebox_hover.border_color = hover_border
	self.add_theme_stylebox_override("normal", stylebox)
	self.add_theme_stylebox_override("hover", stylebox_hover)
	self.add_theme_stylebox_override("pressed", stylebox)
