extends CanvasLayer

@export var bad_shader_rect: ColorRect

func update_bad_path_effect(bad_path_points: int):
	if not bad_shader_rect or not bad_shader_rect.material:
		print("Warning: BadShaderRect or its material not set up properly")
		return

	var intensity: float = 0.0

	if bad_path_points >= 3 and bad_path_points < 5:
		intensity = 0.3
	elif bad_path_points >= 5 and bad_path_points < 7:
		intensity = 0.6
	elif bad_path_points >= 7 and bad_path_points < 10:
		intensity = 0.8
	elif bad_path_points >= 10:
		intensity = 1.0
		trigger_bad_ending_2()

	var shader_material = bad_shader_rect.material as ShaderMaterial
	shader_material.set_shader_parameter("intensity", intensity)

func trigger_bad_ending_2():
	print("Bad Ending 2 triggered - Complete isolation")
