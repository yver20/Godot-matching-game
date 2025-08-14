extends Node2D

#This is where stuff like boardsize is given to the other managers, and where information regarding matching is transferred between them.

var gridSizeX: int = 8
var gridSizeY: int = 8
var spacing: int = 1000

@onready var Gm: Node2D = $GridManager
@onready var Pm: Node2D = $PieceManager

func _ready() -> void:
	
	Gm.gridSizeX = gridSizeX
	Gm.gridSizeY = gridSizeY
	Gm.spacing = spacing
	
	Pm.gridSizeX = gridSizeX
	Pm.gridSizeY = gridSizeY
	Pm.spacing = spacing
	
	Gm._generate_grid()
	Pm._generate_pieces()
