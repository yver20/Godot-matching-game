extends Node2D

var val = randi_range(0, 6)

func _ready() -> void:
	print("I exist!")
	print("children:")
	print(get_child(0).name)
