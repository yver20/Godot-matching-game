extends StaticBody2D

const gridSizeX = 7
const gridSizeY = 7

@onready var empty_thing: Node2D = $"Empty Thing"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n in gridSizeX:
		for i in gridSizeY:
			print("duplicating...")
			var gridPiece = empty_thing.duplicate()
			add_child(gridPiece)
			gridPiece.global_position.y = n * 900
			gridPiece.global_position.x = i * 900


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
