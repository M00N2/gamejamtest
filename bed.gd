extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var collision_shape_2d: CollisionShape2D = $Interactable/CollisionShape2D

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	print("you have touched the bed")
	
