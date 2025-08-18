extends Node2D

signal scoreUpdate(score: int)

var gridSizeX: int
var gridSizeY: int
var spacing: int
var maximumSwapRange: int
var typeCount: int
var mustMatch: bool
var refillAlgorithm: String
var gameSpeed: float
#We can increase difficulty by increasing this number.
var minimumMatchSize = 3

var pieces = [] # This will be board[x][y]
var currentlyDraggedPiece: Area2D = null
var swappingPiece: Area2D
var orderCount: int = 0
#all algorithms that are not an 'algorithm randomizer'. to be used for said randomizers which are currently 'moodswing' and 'chaos'
var algorithms: Array = ['random','order','balanced','assisting','fighting']

var score: int = 0

var resolved: bool = true

@onready var pieceScene: Area2D = $Piece

func _ready() -> void:
	print("Piece manager exists")

#This function should be run at the beginning of the game, generating a new board of pieces.
func _generate_pieces() -> void:
	resolved = false
	print("Generating pieces...")
	pieces.resize(gridSizeX)
	for x in gridSizeX:
		pieces[x] = []
		for y in gridSizeY:
			pieces[x].append(null)
			_generate_new_piece(x, y)
	if _check_for_matches(false):
		await _apply_gravity_to_pieces()
		while _check_for_matches(false):
			await _apply_gravity_to_pieces()
	resolved = true
#The above logic divides the grid in columns. Every array in the 'pieces' array is one column.

#Simple and effective. clears all pieces. (assuming they're stored in the 2D array correctly)
func _clear_pieces() -> void:
	for x in pieces.size():
		for y in pieces[x].size():
			if pieces[x][y] != null:
				pieces[x][y].queue_free()

func _generate_new_piece(x: int, y: int, algorithm = 'random') -> void:
	#This is basically my current 'refill algorithm'
	#I'm assuming I will be able to apply other algorithms to one piece at a time as well.
	var currentPiece = pieceScene.duplicate()
	add_child(currentPiece)
	match algorithm:
		'random': currentPiece.pieceType = randi_range(0,typeCount-1)
		'order':
			currentPiece.pieceType = orderCount
			orderCount += 1
			if orderCount == typeCount: orderCount = 0
		'balanced':#This algorithm will try to 'balance' the board by preffering pieces that are currently less common on the board
			#Note for balanced: We can't just put in the least occurring piece every time. Then we'd immediately create a match once its 3 or less than the second least occurring piece. (do the logic)
			var typeCounter: Array
			var types: Array
			for t in typeCount:
				typeCounter.append(0)
				types.append(t)
			
			var gridSize: int
			
			for gridX in pieces.size():
				for gridY in pieces[gridX].size():
					# go through each piece, and check the piece type. Increment that array entry.
					# We're counting how many of each type exist on the board.
					# In theory, I could also keep track of this as pieces are created. Then, I wouldn't have to go through all pieces. every time I make a new piece.
					if pieces[gridX][gridY] != null:
						typeCounter[pieces[gridX][gridY].pieceType] += 1
						gridSize += 1
			
			#print(typeCounter)
			#print(gridSize)
			#set each types rarity to the reverse rarity in percentage (for example, (1 - (5/25))*100 = 80 AKA the opposite of it's percentage of presence)
			for t in typeCounter.size():
				typeCounter[t] = (1 - (float(typeCounter[t]) / float(gridSize))) * 100
				print("chance of piece: " + str(t) + " = " + str(typeCounter[t]) + "%")
			
			
			#Types is an array containing the index of each type. the RNG randomly picks one with the rarity we calculated.
			currentPiece.pieceType = types[RandomNumberGenerator.new().rand_weighted(typeCounter)]
		'assisting': #This algorithm will try to 'assist' the player by creating pieces in such a way that they can be used to make a new match (soon tm)
			var valid_types = []
			for t in typeCount:
				# temporarily "place" this type in the empty slot
				currentPiece.pieceType = t
				pieces[x][y] = currentPiece  
				# check if this placement creates any possible swap that would yield a match
				if _valid_move_at(x, y):
					valid_types.append(t)
			# if there are any pieces left, those will allow matches. pick one of those as the type
			if !valid_types.is_empty():
				currentPiece.pieceType = valid_types[randi() % valid_types.size()]
				# fallback: no types would allow a match, so just pick one at random
			else: currentPiece.pieceType = randi_range(0,typeCount-1)
		'fighting':
			#This algorithm will try to 'fight' the player by creating pieces that can't be used to create matches in their new spots.
			#obviously, you'll still be able to make matches with these pieces, just not in your next move.
			#Note for 'fighting': Guarranteed to never create 'computer cascades' on its own, unless it's part of the plan to rid the player of moves.
			var valid_types = []
			for t in typeCount:
				# temporarily "place" this type in the empty slot
				currentPiece.pieceType = t
				pieces[x][y] = currentPiece  
				# check if this placement creates any possible swap that would yield a match
				if not _valid_move_at(x, y):
					valid_types.append(t)
			# if there are any pieces left, those will not allow matches. pick one of those as the type
			if !valid_types.is_empty():
				currentPiece.pieceType = valid_types[randi() % valid_types.size()]
				# fallback: all types would allow a match, so just pick one at random
			else: currentPiece.pieceType = randi_range(0,typeCount-1)
		_: currentPiece.pieceType = randi_range(0,typeCount-1) #when in doubt, just make a random piece
	
	currentPiece.add_to_group("pieces")
	currentPiece.global_position = Vector2(x*spacing, y*spacing)
	currentPiece.gridPos =  Vector2(x,y)
	currentPiece._initialize_piece()
	
	currentPiece.connect("input_event", Callable(self, "_on_piece_input_event").bind(currentPiece))
	currentPiece.connect("area_entered", Callable(self, "_on_piece_area_entered").bind(currentPiece))
	currentPiece.connect("area_exited", Callable(self, "_on_piece_area_exited").bind(currentPiece))
	
	pieces[x][y] = currentPiece

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		print("debug power go!")
		print(_find_all_valid_moves())
		print("")

func _on_piece_input_event(viewport: Node, event: InputEvent, shape_idx: int, piece: Area2D) -> void:
	#picking up a piece
	if event.is_action_pressed("grab") and resolved:
		piece.oldPosition = piece.global_position
		piece.savedPosition = piece.global_position
		piece.get_node("Image").z_index = 1
		currentlyDraggedPiece = piece

#dropping a piece
	elif event.is_action_released("grab") and currentlyDraggedPiece:
		resolved = false
		#print("bruh")
		print(swappingPiece)
		if swappingPiece != null:
			#print(currentlyDraggedPiece.savedPosition) #also check it's current position
			#set the position of the dragged piece to whatever you landed on. If it's invalid, it'll reset to its old eventually anyway
			currentlyDraggedPiece.global_position = currentlyDraggedPiece.savedPosition
			_update_piece_grid_position(swappingPiece)
			_update_piece_grid_position(currentlyDraggedPiece)
			if _check_for_matches(true):
				if currentlyDraggedPiece != null: #in this scenario, there was a match
					currentlyDraggedPiece.get_node("Image").z_index = 0
					currentlyDraggedPiece.oldPosition = currentlyDraggedPiece.savedPosition
					swappingPiece.oldPosition = swappingPiece.global_position
					currentlyDraggedPiece = null
					swappingPiece = null
				await _apply_gravity_to_pieces()
				while _check_for_matches(true):
					await _apply_gravity_to_pieces()
			elif mustMatch: #Here, no valid match was found, so the move was invalid. We need to return the swapped pieces.
				_reset_piece_position(currentlyDraggedPiece)
				_reset_piece_position(swappingPiece)
				currentlyDraggedPiece.get_node("Image").z_index = 0
			else: #in this scenario, matching is optional, but no match was made.
				#No resets needed, but we do need to drop the current piece.
				currentlyDraggedPiece.oldPosition = currentlyDraggedPiece.savedPosition
				swappingPiece.oldPosition = swappingPiece.global_position
				currentlyDraggedPiece.get_node("Image").z_index = 0
			#_confirm_piece_position(swappingPiece)
		else: #here, we didn't actually move the dragged piece to a valid spot, so it needs to be reset.
			_reset_piece_position(currentlyDraggedPiece)
			currentlyDraggedPiece.get_node("Image").z_index = 0
		currentlyDraggedPiece = null
		swappingPiece = null
		#for x in pieces.size():
			#for y in pieces[x].size():
				#if pieces[x][y] != null:
					#_update_piece_grid_position(pieces[x][y])
		resolved = true
		_print_board_state() #this can be uncommented to check if moving is stored correctly.


func _on_piece_area_entered(other: Area2D, piece: Area2D) -> void:
	if currentlyDraggedPiece == piece:
		if other.is_in_group("tiles"):
			if _are_pieces_in_range(piece, other):
				piece.savedPosition = other.global_position
				if swappingPiece != null:
					_reset_piece_position(swappingPiece)
				swappingPiece = pieces[other.gridPos.x][other.gridPos.y]
				# Swap positions
				_move_other_piece(piece, swappingPiece)

func _on_piece_area_exited(other: Area2D, piece: Area2D) -> void:
	if currentlyDraggedPiece == piece:
		if other.is_in_group("tiles") and other.global_position != piece.oldPosition:
			if swappingPiece != null:
				if other.global_position == swappingPiece.oldPosition:
					_reset_piece_position(swappingPiece)
					piece.savedPosition = piece.oldPosition
					swappingPiece = null
		#elif other.is_in_group("pieces"):
			#other.savedPosition = other.oldPosition

func _confirm_piece_position(piece: Area2D) -> void:
	piece.global_position = piece.savedPosition
	piece.oldPosition = piece.savedPosition

#swaps the saved positions of the dragged piece and the piece you're hovering over. Also visually moves the other piece to your original location
func _move_other_piece(draggedPiece: Area2D, otherPiece: Area2D) -> void:
	otherPiece.global_position = draggedPiece.oldPosition

func _reset_piece_position(piece: Area2D) -> void:
	piece.global_position = piece.oldPosition
	piece.savedPosition = piece.oldPosition
	_update_piece_grid_position(piece)

func _are_pieces_in_range(pieceA, pieceB) -> bool:
	var dX = abs(pieceA.gridPos.x - pieceB.gridPos.x)
	var dY = abs(pieceA.gridPos.y - pieceB.gridPos.y)
	 # straight line only (not diagonal)
	var isStraightLine = (dX == 0 or dY == 0)
	# distance within allowed range
	var withinRange = (dX + dY) <= maximumSwapRange
	return isStraightLine and withinRange

#This complex function goes through the current 2D array of pieces and identifies all lines of same-type pieces and removes them.
func _check_for_matches(scoring: bool) -> bool:

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
			if previousPiece != null and pieces[x][currentRow] != null:
				if pieces[x][currentRow].pieceType == previousPiece.pieceType: #if the type of the previous piece is the same as the piece currently being checked, we can begin matching shenanigans.
					matchCount += 1 #two pieces have lined up at least.
				else: #the chain is broken because the previous piece was different
					if matchCount >= minimumMatchSize: #If the line of pieces is 3 or more (by default, see minimumMatchSize) a valid match is created, and all of the found pieces need to be noted
						#now that the chain is done, we simply add each of the noted pieces in the currentMatch to the main matchedPieces Array.
						matchedPieces.append_array(currentMatch)
					currentMatch.clear()
					matchCount = 1 #reset count to 1, with the current piece becoming 'number one' in the chain.
			else: #the chain is broken because there was no previous piece
				if matchCount >= minimumMatchSize: #If the line of pieces is 3 or more (by default, see minimumMatchSize) a valid match is created, and all of the found pieces need to be noted
					#now that the chain is done, we simply add each of the noted pieces in the currentMatch to the main matchedPieces Array.
					matchedPieces.append_array(currentMatch)
				currentMatch.clear()
				matchCount = 1 #reset count to 1, with the current piece being 'number one' in the chain.
			currentMatch.append(pieces[x][currentRow])
			previousPiece = pieces[x][currentRow] #current piece becomes the new 'previous piece' before the next piece is checked
		#here, the current row has been completely checked. we don't want a chain to continue over to the next row, so we need to clear the previousPiece. This will make sure the next row of checks begin with 'null' which will never match.
		#technically we don't need to also clear the currentMatch, as it will be reset anyway because 'the chain will be broken' at the start of the next row
		currentRow += 1
		previousPiece = null
		continue
	
	#vertical check:
	for x in pieces.size():
		for y in pieces[x].size():
			if previousPiece != null and pieces[x][y] != null:
				if pieces[x][y].pieceType == previousPiece.pieceType: #if the type of the previous piece is the same as the piece currently being checked, we can begin matching shenanigans.
					matchCount += 1 #two pieces have lined up at least.
				else: #the chain is broken because the previous piece was different
					if matchCount >= minimumMatchSize: #If the line of pieces is 3 or more (by default, see minimumMatchSize) a valid match is created, and all of the found pieces need to be noted
						#now that the chain is done, we simply add each of the noted pieces in the currentMatch to the main matchedPieces Array.
						for p in currentMatch.size():
							if !matchedPieces.has(currentMatch[p]):
								matchedPieces.append(currentMatch[p])
					currentMatch.clear()
					matchCount = 1 #reset count to 1, with the current piece becoming 'number one' in the chain.
			else: #the chain is broken because there was no previous piece
				if matchCount >= minimumMatchSize: #If the line of pieces is 3 or more (by default, see minimumMatchSize) a valid match is created, and all of the found pieces need to be noted
					#now that the chain is done, we simply add each of the noted pieces in the currentMatch to the main matchedPieces Array.
					for p in currentMatch.size():
							if !matchedPieces.has(currentMatch[p]):
								matchedPieces.append(currentMatch[p])
				currentMatch.clear()
				matchCount = 1 #reset count to 1, with the current piece being 'number one' in the chain.
			currentMatch.append(pieces[x][y])
			previousPiece = pieces[x][y] #current piece becomes the new 'previous piece' before the next piece is checked
		#here, the current row has been completely checked. we don't want a chain to continue over to the next row, so we need to clear the previousPiece. This will make sure the next row of checks begin with 'null' which will never match.
		#technically we don't need to also clear the currentMatch, as it will be reset anyway because 'the chain will be broken' at the start of the next row
		previousPiece = null
	
	#At this point, the loop has ended, but if there was a match, we never got to finish it. final check to see if there is a match at the corner
	if matchCount >= minimumMatchSize: #If the line of pieces is 3 or more (by default, see minimumMatchSize) a valid match is created, and all of the found pieces need to be noted
		#now that the chain is done, we simply add each of the noted pieces in the currentMatch to the main matchedPieces Array.
		for p in currentMatch.size():
				if !matchedPieces.has(currentMatch[p]):
					matchedPieces.append(currentMatch[p])
	
	#finally, remove all matching pieces:
	if !matchedPieces.is_empty():
		if scoring:
			score += matchedPieces.size()
			scoreUpdate.emit(score)
		for x in matchedPieces.size():
			pieces[matchedPieces[x].gridPos.x][matchedPieces[x].gridPos.y] = null
			matchedPieces[x].queue_free()
			matchedPieces[x] = null
		matchedPieces.clear()
		return true
	else: return false

#this updates a piece's information regarding it's position on the grid.
#not only is the pieces 2D array updated, but also the variable of the piece keeping track of it's own position.
func _update_piece_grid_position(piece: Area2D) -> void:
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

#This prints the current board state by printing the types of each row of pieces.
func _print_board_state() -> void:
	var pieceTypes = []
	var boardHeight = pieces[0].size()
	var currentRow = 0
	while currentRow < boardHeight:
		for x in pieces.size():
			if pieces[x][currentRow] != null:
				pieceTypes.append(pieces[x][currentRow].pieceType)
			else:
				pieceTypes.append("n")
		print(pieceTypes)
		pieceTypes.clear()
		currentRow += 1
		continue
	print("")

#This function checks whether or not there are three or more pieces in a row on the given position.
#On a normal board state this will always return false, as there should not be any matches then.
#However this can be used in conjunction with hypothetical board states to check for valid swaps or computer cascades
func _is_match_at(x: int, y: int) -> bool:
	var piece = pieces[x][y]
	if piece == null:
		return false
	
	var type = piece.pieceType
	
	# Horizontal scan
	var count = 1
	var left = x - 1
	while left >= 0 and pieces[left][y] and pieces[left][y].pieceType == type:
		count += 1
		left -= 1
	var right = x + 1
	while right < gridSizeX and pieces[right][y] and pieces[right][y].pieceType == type:
		count += 1
		right += 1
	if count >= 3:
		return true

# Vertical scan
	count = 1
	var up = y - 1
	while up >= 0 and pieces[x][up] and pieces[x][up].pieceType == type:
		count += 1
		up -= 1
	var down = y + 1
	while down < gridSizeY and pieces[x][down] and pieces[x][down].pieceType == type:
		count += 1
		down += 1
	if count >= 3:
		return true
	
	return false

#This fucntion goes through all spots on the board, does a fake swap, and then checks if that would cause a match using the match checker function.
#It returns a list of all valid moves, described as from, to a position. I prefer to count starting at 1, so 1 is added to the coordinate result.
func _find_all_valid_moves() -> Array:
	var moves = []
	for x in gridSizeX:
		for y in gridSizeY:
			if pieces[x][y] == null:
				continue
			
			# Only need to check right + down neighbors
			var neighbors = [[1,0], [0,1]]
			for offset in neighbors:
				var nx = x + offset[0]
				var ny = y + offset[1]
				if nx >= gridSizeX or ny >= gridSizeY:
					continue
				if pieces[nx][ny] == null:
					continue
				
				# Swap temporarily
				var temp = pieces[x][y]
				pieces[x][y] = pieces[nx][ny]
				pieces[nx][ny] = temp
				
				# Check if swap creates match
				if _is_match_at(x, y) or _is_match_at(nx, ny):
					moves.append({"from": Vector2(x+1,y+1), "to": Vector2(nx+1,ny+1)})
				
				# Swap back
				temp = pieces[x][y]
				pieces[x][y] = pieces[nx][ny]
				pieces[nx][ny] = temp
	
	if moves.is_empty():
		moves.append("No valid moves!")
	return moves

#This function checks to see if there are any valid moves to be made (that are 1 square away) at the given position
func _valid_move_at(x: int, y: int) -> bool:
	var neighbors = [[1,0], [-1,0], [0,1], [0,-1]]
	for offset in neighbors:
		var nx = x + offset[0]
		var ny = y + offset[1]
		if nx < 0 or nx >= gridSizeX or ny < 0 or ny >= gridSizeY:
			continue
		if pieces[nx][ny] == null:
			continue
		
		var temp = pieces[x][y]
		pieces[x][y] = pieces[nx][ny]
		pieces[nx][ny] = temp
		
		if _is_match_at(x, y) or _is_match_at(nx, ny):
			# swap back before returning!
			temp = pieces[x][y]
			pieces[x][y] = pieces[nx][ny]
			pieces[nx][ny] = temp
			return true
		
		temp = pieces[x][y]
		pieces[x][y] = pieces[nx][ny]
		pieces[nx][ny] = temp
	return false

#This will make all pieces with empty slots directly under them drop one spot.
func _apply_gravity_to_pieces() -> void:
	for x in pieces.size():
		await _apply_gravity_to_column(pieces[x])
		await get_tree().create_timer(0.025/gameSpeed).timeout
	await get_tree().create_timer(0.1/gameSpeed).timeout
	await _refill_board()
	await get_tree().create_timer(0.1/gameSpeed).timeout

func _apply_gravity_to_column(column: Array) -> void:
	for y in range(column.size() - 2, -1, -1):
		var newY = y
		if column[y] != null:
			while newY + 1 < column.size() and column[newY + 1] == null:
				newY += 1
			if newY != y:
				column[y].global_position = Vector2(column[y].global_position.x, newY*spacing)
				column[y].oldPosition = column[y].global_position
				column[y].savedPosition = column[y].global_position
				_update_piece_grid_position(column[y])

func _refill_board() -> void:
	var algorithmToBeUsed
	if refillAlgorithm == 'moodswing':
		algorithmToBeUsed = algorithms[randi() % algorithms.size()]
		print("current refill: " + algorithmToBeUsed)
		for x in pieces.size():
			for y in pieces[x].size():
				if pieces[x][y] == null:
					await get_tree().create_timer(0.01/gameSpeed).timeout
					_generate_new_piece(x,y, algorithmToBeUsed)
	elif refillAlgorithm == 'chaos':
		for x in pieces.size():
			for y in pieces[x].size():
				if pieces[x][y] == null:
					algorithmToBeUsed = algorithms[randi() % algorithms.size()]
					await get_tree().create_timer(0.01/gameSpeed).timeout
					_generate_new_piece(x,y, algorithmToBeUsed)
	else:
		for x in pieces.size():
			for y in pieces[x].size():
				if pieces[x][y] == null:
					await get_tree().create_timer(0.01/gameSpeed).timeout
					_generate_new_piece(x,y, algorithmToBeUsed)

func _process(delta: float) -> void:
	if currentlyDraggedPiece != null:
		currentlyDraggedPiece.global_position = get_global_mouse_position()
