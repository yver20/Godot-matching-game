extends Node2D

var gridPos: Vector2
#this is the X and Y positons 'on the grid' rather than its physical position in the world
#This should be useful for debugging and double checking where matches are made

@onready var collider: Node2D = $GridCollider

func _ready() -> void:
	collider.add_to_group("tileColliders")
