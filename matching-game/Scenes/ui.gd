extends Node2D

signal newValue(newValue: int, type: String)
signal newBoard

func _on_vertical_slider_value_changed(value: float) -> void:
	newValue.emit(value, 'vertical')


func _on_horizontal_slider_value_changed(value: float) -> void:
	newValue.emit(value, 'horizontal')


func _on_pieces_slider_value_changed(value: float) -> void:
	newValue.emit(value, 'pieces')


func _on_new_board_button_pressed() -> void:
	newBoard.emit()
