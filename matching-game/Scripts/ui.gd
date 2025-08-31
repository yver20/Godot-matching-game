extends Node2D

signal newValue(newValue, type: String)
signal newBoard

@onready var scoreText: RichTextLabel = $Score

func _on_new_board_button_pressed() -> void:
	newBoard.emit()

func _on_vertical_slider_value_changed(value: float) -> void:
	newValue.emit(value, 'vertical')


func _on_horizontal_slider_value_changed(value: float) -> void:
	newValue.emit(value, 'horizontal')


func _on_pieces_slider_value_changed(value: float) -> void:
	newValue.emit(value, 'pieces')


func _on_range_slider_value_changed(value: float) -> void:
	newValue.emit(value, 'range')


func _on_match_toggle_toggled(toggled_on: bool) -> void:
	newValue.emit(toggled_on, 'match')


func _on_refill_select_item_selected(index: int) -> void:
	match index:
		0: newValue.emit('random', 'refill')
		1: newValue.emit('order', 'refill')
		2: newValue.emit('balanced', 'refill')
		3: newValue.emit('assisting', 'refill')
		4: newValue.emit('fighting', 'refill')
		5: newValue.emit('moodswing', 'refill')
		6: newValue.emit('chaos', 'refill')


func _on_game_speed_slider_value_changed(value: float) -> void:
	newValue.emit(value, 'speed')


func _on_board_manager_score_update(score: int) -> void:
	scoreText.text = "score %s" % str(score)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
