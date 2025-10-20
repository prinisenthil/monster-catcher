extends Label

var _full_text := ""
var _typing := false
var _interrupt := false
@export var char_delay := 0.03

func type_text(new_text: String) -> void:
	_interrupt = true  # Stop any previous typing
	if get_tree():
		await get_tree().process_frame  # Give it a moment to stop
	_interrupt = false

	_typing = true
	_full_text = new_text
	text = ""

	for i in new_text.length():
		if _interrupt:
			break
		text += new_text[i]
		if get_tree():
			await get_tree().create_timer(char_delay).timeout

	if _interrupt:
		text = new_text  # Instantly finish text
		if get_tree():
			await get_tree().create_timer(0.5).timeout
	_typing = false

func is_typing() -> bool:
	return _typing

func skip():
	_interrupt = true
