extends StaticBody2D

const gridSizeX = 10
const gridSizeY = 10

@onready var empty_thing: Node2D = $"Empty Thing"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n in gridSizeX:
		print("duplicating...")
		var gridPiece = empty_thing.duplicate()
		add_child(gridPiece)
		gridPiece.get_node()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
