extends Area2D

const gridSizeX = 7
const gridSizeY = 7
const spacing = 900

@onready var piece: Node2D = $Piece
@onready var gridNode: Area2D = $GridCollider



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for x in gridSizeX:
		for y in gridSizeY:
			var grid = gridNode.duplicate()
			add_child(grid)
			grid.global_position = Vector2(x*spacing, y*spacing)
			grid.add_to_group("grid")

	for x in gridSizeX:
		for y in gridSizeY:
			#print("duplicating...")
			var gridPiece = piece.duplicate()
			add_child(gridPiece)
			gridPiece.add_to_group("pieces")
			gridPiece.global_position = Vector2(x*spacing, y*spacing)
			gridPiece.connect("area_entered", Callable(gridPiece, "_on_area_entered"))
			gridPiece.connect("area_exited", Callable(gridPiece, "_on_area_exited"))
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
