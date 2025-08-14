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
	#print("bruh")
	if event.is_action_pressed("grab"):
		currentlyDraggedPiece = piece
		piece.oldPosition = piece.global_position
		piece.savedPosition = piece.global_position
		piece.get_node("Image").z_index = 1

	elif event.is_action_released("grab") and currentlyDraggedPiece:
		#print("bruh")
		currentlyDraggedPiece.global_position = currentlyDraggedPiece.savedPosition
		currentlyDraggedPiece.get_node("Image").z_index = 0
		currentlyDraggedPiece = null
		if swappingPiece:
			swappingPiece.global_position = swappingPiece.savedPosition
			swappingPiece.oldPosition = global_position

func _on_piece_area_entered(other: Area2D, piece: Area2D) -> void:
	if currentlyDraggedPiece == piece:
		if other.is_in_group("tileColliders"):
			piece.savedPosition = other.global_position
		elif other.is_in_group("pieces"):
			# Swap positions
			piece.savedPosition = other.oldPosition
			other.savedPosition = piece.oldPosition
			swappingPiece = other

func _on_piece_area_exited(other: Area2D, piece: Area2D) -> void:
	if currentlyDraggedPiece == piece:
		if other.is_in_group("tileColliders"):
			piece.savedPosition = piece.oldPosition
		elif other.is_in_group("pieces"):
			other.savedPosition = other.oldPosition
			swappingPiece = null

func _process(delta: float) -> void:
	if currentlyDraggedPiece:
		currentlyDraggedPiece.global_position = get_global_mouse_position()
