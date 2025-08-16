extends Button

@export var computer_path: NodePath
@onready var computer: Node = get_node(computer_path)

func _pressed() -> void:
	if computer and computer.has_method("_close_computer"):
		computer._close_computer()
