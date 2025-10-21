extends ColorRect

@onready var mat := material

func highlight_node(node: Control):
	var rect = node.get_global_rect()
	var viewport_size = get_viewport_rect().size

	var center = rect.get_center() / viewport_size
	mat.set_shader_parameter("rect_pos", center)
	mat.set_shader_parameter("rect_size", rect.size)
