extends Node2D

var gridSizeX: int
var gridSizeY: int
var spacing: int

var pieces = [] # This will be board[x][y]
var currentlyDraggedPiece: Area2D = null
var swappingPiece: Area2D

@onready var pieceScene: Area2D = $Piece

func _ready() -> void:
	print("Piece manager exists")

#This function should be run at the beginning of the game, generating a new board of pieces.
func _generate_pieces() -> void:
	
	print("Generating pieces...")
	pieces.resize(gridSizeX)
	for x in gridSizeX:
		pieces[x] = []
		for y in gridSizeY:
			var currentPiece = pieceScene.duplicate()
			add_child(currentPiece)
			currentPiece.pieceType = randi_range(0,6)
			currentPiece.add_to_group("pieces")
			currentPiece.global_position = Vector2(x*spacing, y*spacing)
			currentPiece.gridPos =  Vector2(x,y)
			currentPiece._initialize_piece()
			
			# Input
			currentPiece.connect("input_event", Callable(self, "_on_piece_input_event").bind(currentPiece))
			# Collision forwarding
			currentPiece.connect("area_entered", Callable(self, "_on_piece_area_entered").bind(currentPiece))
			currentPiece.connect("area_exited", Callable(self, "_on_piece_area_exited").bind(currentPiece))
			#current piece needs to be bound instead?
			
			pieces[x].append(currentPiece)
#The above logic divides the grid in rows. Every array in the 'pieces' array is one row.
#In other words, every 1st entry in one of the arrays of 'pieces' is part of the left most column, every second entry is part of the column to the right of that, and so on.


func _on_piece_input_event(viewport: Node, event: InputEvent, shape_idx: int, piece: Area2D) -> void:
	#picking up a piece
	if event.is_action_pressed("grab"):
		currentlyDraggedPiece = piece
		piece.oldPosition = piece.global_position
		piece.savedPosition = piece.global_position
		piece.get_node("Image").z_index = 1

#dropping a piece
	elif event.is_action_released("grab") and currentlyDraggedPiece:
		#print("bruh")
		currentlyDraggedPiece.global_position = currentlyDraggedPiece.savedPosition
		currentlyDraggedPiece.get_node("Image").z_index = 0
		if swappingPiece:
			swappingPiece.global_position = swappingPiece.savedPosition
			swappingPiece.oldPosition = swappingPiece.global_position
			_update_piece_position(currentlyDraggedPiece)
			_update_piece_position(swappingPiece)
			_print_board_state() #this can be uncommented to check if moving is stored correctly.
		currentlyDraggedPiece = null

func _print_board_state() -> void:
	var pieceTypes = []
	var boardHeight = pieces[0].size()
	var currentRow = 0
	while currentRow < boardHeight:
		for x in pieces.size():
			pieceTypes.append(pieces[x][currentRow].pieceType)
		print(pieceTypes)
		pieceTypes.clear()
		currentRow += 1
		continue
	print("")

func _check_for_matches() -> void:
	pass

func _on_piece_area_entered(other: Area2D, piece: Area2D) -> void:
	if currentlyDraggedPiece == piece:
		if other.is_in_group("tileColliders"):
			piece.savedPosition = other.global_position
		elif other.is_in_group("pieces"):
			# Swap positions
			piece.savedPosition = other.global_position
			other.savedPosition = piece.oldPosition
			swappingPiece = other

func _on_piece_area_exited(other: Area2D, piece: Area2D) -> void:
	if currentlyDraggedPiece == piece:
		if other.is_in_group("tileColliders"):
			piece.savedPosition = piece.oldPosition
		elif other.is_in_group("pieces"):
			other.savedPosition = other.oldPosition
			swappingPiece = null

#this updates a piece's information regarding it's position on the grid.
#not only is the pieces 2D array updated, but also the variable of the piece keeping track of it's own position.
func _update_piece_position(piece: Area2D) -> void:
		# Remove the piece from its old location in the array
	var old_x = int(piece.gridPos.x)
	var old_y = int(piece.gridPos.y)
	if old_x >= 0 and old_x < gridSizeX and old_y >= 0 and old_y < gridSizeY:
		if pieces[old_x][old_y] == piece:
			pieces[old_x][old_y] = null  # Clear old spot
	
	# Calculate new grid coordinates from its world position
	var new_x = int(round(piece.global_position.x / spacing))
	var new_y = int(round(piece.global_position.y / spacing))
	
	# Update logical position
	piece.gridPos = Vector2(new_x, new_y)
	pieces[new_x][new_y] = piece

func _process(delta: float) -> void:
	if currentlyDraggedPiece:
		currentlyDraggedPiece.global_position = get_global_mouse_position()
