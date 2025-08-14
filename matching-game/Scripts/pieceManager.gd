extends Node2D

var gridSizeX: int
var gridSizeY: int
var spacing: int

var pieces = [] # This will be board[y][x]

@onready var piece: Area2D = $Piece

func _ready() -> void:
	print("Piece manager exists")


func _generate_pieces() -> void:
	
	print("Generating pieces...")
	pieces.resize(gridSizeX)
	for x in gridSizeX:
		pieces[x] = []
		for y in gridSizeY:
			var currentPiece = piece.duplicate()
			add_child(currentPiece)
			currentPiece.add_to_group("pieces")
			currentPiece.global_position = Vector2(x*spacing, y*spacing)
			currentPiece.gridPos =  Vector2(x,y)
			currentPiece.connect("area_entered", Callable(currentPiece, "_on_area_entered"))
			currentPiece.connect("area_exited", Callable(currentPiece, "_on_area_exited"))
			
			pieces[x].append(currentPiece)
#The above logic divides the grid in rows. Every array in the 'pieces' array is one row.
#In other words, every 1st entry in one of the arrays of 'pieces' is part of the left most column, every second entry is part of the column to the right of that, and so on.
