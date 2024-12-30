extends StaticBody2D

const gridSizeX = 10
const gridSizeY = 10

@onready var empty_thing: Node2D = $"Empty Thing"
const AWESOME_FACE = preload("res://sprites/awesome face.jpg")
const _000_SPIKE_FACTORY = preload("res://sprites/000-SpikeFactory.webp")
const JIM = preload("res://sprites/Jim.PNG")
const LOADING = preload("res://sprites/Loading.png")
const PYTHON = preload("res://sprites/Python.png")
const ROBO_BOY = preload("res://sprites/Robo boy.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n in gridSizeX:
		for i in gridSizeY:
			print("duplicating...")
			var gridPiece = empty_thing.duplicate()
			add_child(gridPiece)
			gridPiece.position.y = n * 500
			gridPiece.position.x = i * 500
			print(gridPiece.val)
			match gridPiece.val:
				0: gridPiece.get_node("Image").texture = AWESOME_FACE
				1: gridPiece.get_node("Image").texture = _000_SPIKE_FACTORY
				2: gridPiece.get_node("Image").texture = JIM
				3: gridPiece.get_node("Image").texture = LOADING
				4: gridPiece.get_node("Image").texture = PYTHON
				5: gridPiece.get_node("Image").texture = ROBO_BOY
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
