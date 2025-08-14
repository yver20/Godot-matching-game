extends Node2D

var gridSizeX: int
var gridSizeY: int
var spacing: int

var tiles = [] # This will be board[y][x]
@onready var tile: Node2D = $GridTile



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Grid manager exists")


func _generate_grid() -> void:
	
	print("Generating Tile Grid...")
	tiles.resize(gridSizeX)
	for x in gridSizeX:
		tiles[x] = []
		for y in gridSizeY:
			var currentTile = tile.duplicate()
			add_child(currentTile)
			currentTile.global_position = Vector2(x*spacing, y*spacing)
			currentTile.gridPos = Vector2(x,y)
			currentTile.add_to_group("tiles")
			tiles[x].append(currentTile)
			
#The above logic divides the grid in columns. Every array in the 'tiles' array is one column.
#In other words, every 1st entry in one of the arrays of 'tiles' is part of the top row, every second entry is part of the second row, and so on.

#Also, as of writing this, the only purpose the tiles have is to provide a collider for the pieces.
#This is so that the pieces can snap to the tile's location when dropped. This could be useful later.
