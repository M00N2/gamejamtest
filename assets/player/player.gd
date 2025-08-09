extends CharacterBody2D

const SPEED = 100.0 

var input_vector: = Vector2.ZERO #base movement is 0
@onready var animation_tree: AnimationTree = $AnimationTree # ready to play animations when cond. met

func _physics_process(_delta: float) -> void:
	
	velocity = Vector2.ZERO #velocity = 0
	
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down") # allows for wasd for movement
	
	if input_vector != Vector2.ZERO:
		var direction_vector: = Vector2(-input_vector.x, input_vector.y) # used in code video would flip movement but used for clarity sake
		update_blend_positions(direction_vector)
	
	velocity = SPEED * input_vector 
	move_and_slide() # movement type 
	
func update_blend_positions(direct_vector:Vector2) -> void:
	animation_tree.set("parameters/StateMachine/MoveState/RunState/blend_position", input_vector) #idk
	animation_tree.set("parameters/StateMachine/MoveState/StandState/blend_position", input_vector)
