extends Area2D

var pieceType: int

var gridPos: Vector2
#this is the X and Y positons 'on the grid' rather than its physical position in the world
#This should be useful for debugging and double checking where matches are made

var clicked = false
var savedPosition: Vector2 #This is where a new position for the currently held piece is stored, and it's applied when the user lets go.
var oldPosition: Vector2 #This is the original position of the piece before moving it. Usefull to have as a default, and for swapping other pieces to it.

const BIG_LOADING = preload("res://sprites/Big-Loading.png")
const BLURRY_JIM = preload("res://sprites/Blurry-Jim.png")
const GREEN_PYTHON = preload("res://sprites/Green-Python.png")
const LONG_SPIKE_FACTORY = preload("res://sprites/Long-SpikeFactory.png")
const STRETCHED_AWESOME_FACE = preload("res://sprites/Stretched-awesome face.png")
const TALL_ROBO_BOY = preload("res://sprites/Tall-Robo boy.png")
const BLUE_BSM_2F_SQUID_BOSS = preload("res://sprites/Blue-BSM2F_Squid_Boss.png")

func _ready() -> void:
	#print("I exist!")
	savedPosition = global_position
	#print("children:")
	#print(get_child(0).name)
	#print(val)
	pieceType = randi_range(0,6)
	match pieceType:
		0: $Image.texture = BIG_LOADING
		1: $Image.texture = BLURRY_JIM
		2: $Image.texture = GREEN_PYTHON
		3: $Image.texture = LONG_SPIKE_FACTORY
		4: $Image.texture = STRETCHED_AWESOME_FACE
		5: $Image.texture = TALL_ROBO_BOY
		6: $Image.texture = BLUE_BSM_2F_SQUID_BOSS
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("grab"):
		var mousePos = get_global_mouse_position()
		if ((mousePos.x <= (global_position.x + 450)) && (mousePos.x >= (global_position.x - 450)) && (mousePos.y <= (global_position.y + 450)) && (mousePos.y >= (global_position.y - 450)) ):
			#print("click here! My position is: ", global_position, ", and the click was at: ", mousePos)
			clicked = true
			$Image.z_index = 1
		savedPosition = global_position
		oldPosition = global_position
		
	if Input.is_action_just_released("grab"):
		if clicked:
			global_position = savedPosition
			$Image.z_index = 0
			clicked = false
		else:
			global_position = savedPosition
	if clicked:
		global_position = get_global_mouse_position()
		print("I'm clicked! saved position is: " + str(savedPosition))
		

func _on_area_entered(area: Area2D) -> void:
	if clicked:
		if area.is_in_group("tileColliders"):
			print("area is in group 'tileColliders'!")
			savedPosition = area.global_position
		if area.is_in_group("pieces"):
			area.savedPosition = oldPosition
		

func _on_area_exited(area: Area2D) -> void:
	if clicked:
		if area.is_in_group("tileColliders"):
			print("area is in group 'tileColliders'!")
			savedPosition = oldPosition
		if area.is_in_group("pieces"):
			area.savedPosition = area.oldPosition
