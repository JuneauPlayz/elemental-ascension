extends ColorRect

@onready var mat := material

func highlight_node(node: Control, scale := 1.0):
	var rect = node.get_global_rect()
	var viewport_size = get_viewport_rect().size

	var center = rect.get_center() / viewport_size
	mat.set_shader_parameter("rect_pos", center)
	mat.set_shader_parameter("rect_size", rect.size * scale)

func highlight_nodes(nodes: Array, scale := 1.0):
	var viewport_size = get_viewport_rect().size

	var rect_positions: Array = []
	var rect_sizes: Array = []

	for node in nodes:
		if not node or not node.is_visible_in_tree():
			continue

		var rect = node.get_global_rect()
		var center = rect.get_center() / viewport_size
		var normalized_size = (rect.size / viewport_size) * scale

		rect_positions.append(center)
		rect_sizes.append(normalized_size)

	mat.set_shader_parameter("rect_count", rect_positions.size())
	mat.set_shader_parameter("rect_positions", rect_positions)
	mat.set_shader_parameter("rect_sizes", rect_sizes)
