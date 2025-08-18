extends Area2D

var pieceType: int

var gridPos: Vector2
#this is the X and Y positons 'on the grid' rather than its physical position in the world
#This should be useful for debugging and double checking where matches are made

var clicked: bool = false
var savedPosition: Vector2 #This is where a new position for the currently held piece is stored, and it's applied when the user lets go.
var oldPosition: Vector2 #This is the original position of the piece before moving it. Usefull to have as a default, and for swapping other pieces to it.

const BLUE = preload("res://sprites/Bejeweled/blue_gem.png")
const RED = preload("res://sprites/Bejeweled/red_gem.png")
const GREEN = preload("res://sprites/Bejeweled/green_gem.png")
const YELLOW = preload("res://sprites/Bejeweled/yellow_gem.png")
const PURPLE = preload("res://sprites/Bejeweled/purple_gem.png")
const ORANGE = preload("res://sprites/Bejeweled/orange_gem.png")
const WHITE = preload("res://sprites/Bejeweled/white_gem.png")
const  BLACK = preload("res://sprites/Bejeweled/black_gem.png")

func _initialize_piece() -> void:
	#This function is here to make sure the piece has the correct data after being created.
	#Could and/or should be expanded as more qualities are added to pieces.
	#print("I exist!")
	savedPosition = global_position
	oldPosition = global_position
	match pieceType:
		0: $Image.texture = BLUE
		1: $Image.texture = RED
		2: $Image.texture = GREEN
		3: $Image.texture = YELLOW
		4: $Image.texture = PURPLE
		5: $Image.texture = ORANGE
		6: $Image.texture = WHITE
		7: $Image.texture = BLACK
		_: $Image.texture = BLUE
		

# Forward collision signals to the manager
func _on_area_entered(area: Area2D) -> void:
	emit_signal("area_entered", self, area)

func _on_area_exited(area: Area2D) -> void:
	emit_signal("area_exited", self, area)
