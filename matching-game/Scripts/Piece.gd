extends Area2D

var pieceType: int

var gridPos: Vector2
#this is the X and Y positons 'on the grid' rather than its physical position in the world
#This should be useful for debugging and double checking where matches are made

var clicked: bool = false
var savedPosition: Vector2 #This is where a new position for the currently held piece is stored, and it's applied when the user lets go.
var oldPosition: Vector2 #This is the original position of the piece before moving it. Usefull to have as a default, and for swapping other pieces to it.

const BIG_LOADING = preload("res://sprites/Big-Loading.png")
const BLURRY_JIM = preload("res://sprites/Blurry-Jim.png")
const GREEN_PYTHON = preload("res://sprites/Green-Python.png")
const LONG_SPIKE_FACTORY = preload("res://sprites/Long-SpikeFactory.png")
const STRETCHED_AWESOME_FACE = preload("res://sprites/Stretched-awesome face.png")
const TALL_ROBO_BOY = preload("res://sprites/Tall-Robo boy.png")
const BLUE_BSM_2F_SQUID_BOSS = preload("res://sprites/Blue-BSM2F_Squid_Boss.png")

func _initialize_piece() -> void:
	#This function is here to make sure the piece has the correct data after being created.
	#Could and/or should be expanded as more qualities are added to pieces.
	#print("I exist!")
	savedPosition = global_position
	oldPosition = global_position
	match pieceType:
		0: $Image.texture = BIG_LOADING
		1: $Image.texture = BLURRY_JIM
		2: $Image.texture = GREEN_PYTHON
		3: $Image.texture = LONG_SPIKE_FACTORY
		4: $Image.texture = STRETCHED_AWESOME_FACE
		5: $Image.texture = TALL_ROBO_BOY
		6: $Image.texture = BLUE_BSM_2F_SQUID_BOSS

# Forward collision signals to the manager
func _on_area_entered(area: Area2D) -> void:
	emit_signal("area_entered", self, area)

func _on_area_exited(area: Area2D) -> void:
	emit_signal("area_exited", self, area)
