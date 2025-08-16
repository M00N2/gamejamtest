extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var collision_shape_2d: CollisionShape2D = $Interactable/CollisionShape2D
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var textbox

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	if not textbox:
		textbox = get_tree().get_first_node_in_group("textbox")
	
	if textbox and textbox.current_state == textbox.State.READY:
		if audio_player:
			audio_player.play()
		# Use queue_text, NOT show_choices for the fridge
		textbox.queue_text("The fridge is empty.")
