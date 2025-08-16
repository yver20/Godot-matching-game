extends Node2D

#This is where stuff like boardsize is given to the other managers, and where information regarding matching is transferred between them.

var gridSizeX: int = 7
var gridSizeY: int = 7
var spacing: int = 1000
var maximumSwapRange: int = 1

@onready var Gm: Node2D = $GridManager
@onready var Pm: Node2D = $PieceManager

func _ready() -> void:
	
	Gm.gridSizeX = gridSizeX
	Gm.gridSizeY = gridSizeY
	Gm.spacing = spacing
	
	Pm.gridSizeX = gridSizeX
	Pm.gridSizeY = gridSizeY
	Pm.spacing = spacing
	Pm.maximumSwapRange = maximumSwapRange
	
	Gm._generate_grid()
	Pm._generate_pieces()
