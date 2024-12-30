extends StaticBody2D

const gridSizeX = 7
const gridSizeY = 7

@onready var empty_thing: Node2D = $"Empty Thing"

const BIG_LOADING = preload("res://sprites/Big-Loading.png")
const BLURRY_JIM = preload("res://sprites/Blurry-Jim.png")
const GREEN_PYTHON = preload("res://sprites/Green-Python.png")
const LONG_SPIKE_FACTORY = preload("res://sprites/Long-SpikeFactory.png")
const STRETCHED_AWESOME_FACE = preload("res://sprites/Stretched-awesome face.png")
const TALL_ROBO_BOY = preload("res://sprites/Tall-Robo boy.png")
const BLUE_BSM_2F_SQUID_BOSS = preload("res://sprites/Blue-BSM2F_Squid_Boss.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n in gridSizeX:
		for i in gridSizeY:
			print("duplicating...")
			var gridPiece = empty_thing.duplicate()
			add_child(gridPiece)
			gridPiece.position.y = n * 900
			gridPiece.position.x = i * 900
			print(gridPiece.val)
			match gridPiece.val:
				0: gridPiece.get_node("Image").texture = BIG_LOADING
				1: gridPiece.get_node("Image").texture = BLURRY_JIM
				2: gridPiece.get_node("Image").texture = GREEN_PYTHON
				3: gridPiece.get_node("Image").texture = LONG_SPIKE_FACTORY
				4: gridPiece.get_node("Image").texture = STRETCHED_AWESOME_FACE
				5: gridPiece.get_node("Image").texture = TALL_ROBO_BOY
				6: gridPiece.get_node("Image").texture = BLUE_BSM_2F_SQUID_BOSS
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
