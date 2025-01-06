extends StaticBody2D

const gridSizeX = 7
const gridSizeY = 7

@onready var piece: Node2D = $Piece
@onready var empty: Node2D = $Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n in gridSizeX:
		for i in gridSizeY:
			var gridNode = empty.duplicate()
			add_child(gridNode)
			gridNode.global_position.y = n * 900
			gridNode.global_position.x = i * 900

	for n in gridSizeX:
		for i in gridSizeY:
			#print("duplicating...")
			var gridPiece = piece.duplicate()
			add_child(gridPiece)
			gridPiece.global_position.y = n * 900
			gridPiece.global_position.x = i * 900


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
