extends Node2D

var gridSizeX: int
var gridSizeY: int
var spacing: int

var pieces = [] # This will be board[x][y]
var currentlyDraggedPiece: Area2D = null
var swappingPiece: Area2D

#This variable is one of the first manipulatable rules for the game. we can increase difficulty by increasing this number.
var minimumMatchSize = 3

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
#The above logic divides the grid in columns. Every array in the 'pieces' array is one column.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		print("debug power go!")
		_check_for_matches()

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
			#_print_board_state() #this can be uncommented to check if moving is stored correctly.
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

	var matchedPieces = []
	
	var currentMatch = []
	var boardHeight = pieces[0].size()
	var currentRow = 0
	var previousPiece = null
	var matchCount = 1 #keeps track of the amount of pieces that are part of the current chain.
	
	#step 1: add the currently checked piece to the 'current match'
	#step 2: check if the previous piece is of the same type as the current piece
	#step 3: if so, increase the match count
	#otherwise, the chain is over, if there was one
	#step 4: if there was a chain of a valid size, we need to add each of the found pieces to the list of matched pieces
	#otherwise, the chain was too short, and we need to clean the tracked pieces and add the current piece back again to begin a new chain.
	
	#horizontal check:
	while currentRow < boardHeight:
		for x in pieces.size():
			currentMatch.append(pieces[x][currentRow])
			if previousPiece != null:
				if pieces[x][currentRow].pieceType == previousPiece.pieceType: #if the type of the previous piece is the same as the piece currently being checked, we can begin matching shenanigans.
					matchCount += 1 #two pieces have lined up at least.
				
				else: #the chain is broken and we can finalize the currently found match
					#first we need to remove the current piece, because it's not part of the chain as it's different from the previous piece
					currentMatch.erase(pieces[x][currentRow])
					if matchCount >= minimumMatchSize: #If the line of pieces is 3 or more (by default, see minimumMatchSize) a valid match is created, and all of the found pieces need to be noted
						
						for p in currentMatch.size(): #now that the chain is done, we simply add each of the noted pieces in the currentMatch to the main matchedPieces Array.
							matchedPieces.append(currentMatch[p])
							
					else: #the chain only had 2 or fewer pieces. not a match. we clear the currentMatch array and add the current piece back in which is the beginning of a possible new chain.
						currentMatch.clear()
						currentMatch.append(pieces[x][currentRow])
					matchCount = 1 #reset count to 1, with the current piece being 'number one' in the chain.
				
			else: #the chain is broken and we can finalize the currently found match
				#first we need to remove the current piece, because it's not part of the chain as it's different from the previous piece
				currentMatch.erase(pieces[x][currentRow])
				if matchCount >= minimumMatchSize: #If the line of pieces is 3 or more (by default, see minimumMatchSize) a valid match is created, and all of the found pieces need to be noted
					
					for p in currentMatch.size(): #now that the chain is done, we simply add each of the noted pieces in the currentMatch to the main matchedPieces Array.
						matchedPieces.append(currentMatch[p])
						
				else: #the chain only had 2 or fewer pieces. not a match. we clear the currentMatch array and add the current piece back in which is the beginning of a possible new chain.
					currentMatch.clear()
					currentMatch.append(pieces[x][currentRow])
				matchCount = 1 #reset count to 1, with the current piece being 'number one' in the chain.
			previousPiece = pieces[x][currentRow] #current piece becomes the new 'previous piece' before the next piece is checked
		#here, the current row has been completely checked. we don't want a chain to continue over to the next row, so we need to clear the previousPiece. This will make sure the next row of checks begin with 'null' which will never match.
		#technically we don't need to also clear the currentMatch, as it will be reset anyway because 'the chain will be broken' at the start of the next row
		currentRow += 1
		previousPiece = null
		continue
	
	#here, all horizontal matches have been checked, and each of the pieces in those matches have been added to the matchedPieces Array
	#Now, we need to check all vertical matches in the same way. This is a little less complex, as the pieces are stored per column by default, so we don't need to do the wierd reverse array checking we do in the horizontal check.
	#however, we do need to compare added pieces to the already added pieces of the array, so that we don't accidentally add the same piece twice.
	#In that scenario, two matches have crossed, and either a T, L or cross match has been created. We'll do special stuff for that later. for now, we'll just not add them to the main list of matched pieces.
	
	#For testing purposes, we'll finalize the matching here first, and add the vertical check later.
	
	for x in matchedPieces.size():
		matchedPieces[x].queue_free()
		matchedPieces[x] = null

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
