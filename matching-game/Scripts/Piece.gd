extends Node2D

var val = randi_range(0, 6)

var clicked = false
var savedPosition

const BIG_LOADING = preload("res://sprites/Big-Loading.png")
const BLURRY_JIM = preload("res://sprites/Blurry-Jim.png")
const GREEN_PYTHON = preload("res://sprites/Green-Python.png")
const LONG_SPIKE_FACTORY = preload("res://sprites/Long-SpikeFactory.png")
const STRETCHED_AWESOME_FACE = preload("res://sprites/Stretched-awesome face.png")
const TALL_ROBO_BOY = preload("res://sprites/Tall-Robo boy.png")
const BLUE_BSM_2F_SQUID_BOSS = preload("res://sprites/Blue-BSM2F_Squid_Boss.png")

func _ready() -> void:
	print("I exist!")
	savedPosition = global_position
	#print("children:")
	#print(get_child(0).name)
	print(val)
	match val:
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
			savedPosition = global_position
			clicked = true
			
	if Input.is_action_just_released("grab"):
		if ((global_position.x <= 0)||(global_position.y <= 0)):
			global_position = savedPosition
		else:
			if ((global_position.x >= 900*7)||(global_position.y >= 900*7)): #this needs input from the max grid size to check the proper distance
				global_position = savedPosition
			else:
				global_position = Vector2((int(global_position.x) - (int(global_position.x)%900))+450,(int(global_position.y) - (int(global_position.y)%900))+450)
		clicked = false
		
	if clicked:
		global_position = get_global_mouse_position()
