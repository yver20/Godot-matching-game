extends Node2D

#This is where stuff like boardsize is given to the other managers, and where information regarding matching is transferred between them.

var gridSizeX: int = 7
var gridSizeY: int = 7
var spacing: int = 1050
var maximumSwapRange: int = 1
var typeCount: int = 7
var mustMatch: bool = true
var refillAlgorithm: String = 'random'

@onready var Gm: Node2D = $GridManager
@onready var Pm: Node2D = $PieceManager



func _delete_current_board() -> void:
	Gm._clear_grid()
	Pm._clear_pieces()

#Make a new board with the current settings!
#Note: don't run without deleting the existing board first.
func _generate_board() -> void:
	
	_delete_current_board()
	
	Gm.gridSizeX = gridSizeX
	Gm.gridSizeY = gridSizeY
	Gm.spacing = spacing
	
	Pm.gridSizeX = gridSizeX
	Pm.gridSizeY = gridSizeY
	Pm.spacing = spacing
	Pm.maximumSwapRange = maximumSwapRange
	Pm.typeCount = typeCount
	Pm.mustMatch = mustMatch
	Pm.refillAlgorithm = refillAlgorithm
	
	Gm._generate_grid()
	Pm._generate_pieces()

#When this is called, the player pressed the button to make a completely new board.
#It's basically the new game button
func _on_ui_new_board() -> void:
	_generate_board()

#This is called whenever the player messes with any of the customizable settings
#The signal tells us what setting changed, so we know what to edit here then.
func _on_ui_new_value(newValue, type: String) -> void:
	match type:
		'horizontal': gridSizeX = int(newValue)
		'vertical': gridSizeY = int(newValue)
		'pieces': typeCount = int(newValue)
		'range': maximumSwapRange = int(newValue)
		'match': mustMatch = newValue
		'refill': refillAlgorithm = newValue
