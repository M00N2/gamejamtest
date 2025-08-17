extends CanvasLayer

@onready var dialog_label: Label = $Panel/DialogLabel

func show_text(text: String):
	dialog_label.text = text
	visible = true
	await get_tree().create_timer(2.0).timeout # stays for 2 seconds
	visible = false
