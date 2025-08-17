extends Node2D

#This is where stuff like boardsize is given to the other managers, and where information regarding matching is transferred between them.

var gridSizeX: int = 7
var gridSizeY: int = 7
var spacing: int = 1000
var maximumSwapRange: int = 1

@onready var Gm: Node2D = $GridManager
@onready var Pm: Node2D = $PieceManager

func _generate_board() -> void:
	
	Gm.gridSizeX = gridSizeX
	Gm.gridSizeY = gridSizeY
	Gm.spacing = spacing
	
	Pm.gridSizeX = gridSizeX
	Pm.gridSizeY = gridSizeY
	Pm.spacing = spacing
	Pm.maximumSwapRange = maximumSwapRange
	
	Gm._generate_grid()
	Pm._generate_pieces()

#When this is called, the player pressed the button to make a completely new board.
#It's basically the new game button
func _on_ui_new_board() -> void:
	pass # Replace with function body.

#This is called whenever the player messes with any of the customizable settings
#The signal tells us what setting changed, so we know what to edit here then.
func _on_ui_new_value(newValue: int, type: String) -> void:
	pass # Replace with function body.
