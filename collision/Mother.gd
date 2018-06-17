extends Node

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	for node1 in get_children():
		for node2 in get_children():
			if node1 > node2:
				check_sat(node1, node2)


func check_sat(node1, node2):
	var axes1 = node1.getAxes()
	var axes2 = node2.getAxes()	
	var edges1 = node1.getEdges()
	var edges2 = node2.getEdges()

	var sac_axes = axes1 + axes2
	for edge1 in edges1:
		for edge2 in edges2:
			sac_axes.append(edge1.cross(edge2))

	var smallest_depth = 1000000
	var action_axis = null
	
	for axis in sac_axes:
		var proj1 = node1.getProjection(axis)
		var proj2 = node2.getProjection(axis)
		if !overlap(proj1, proj2):
			return
		elif depth(proj1, proj2) < smallest_depth:
			smallest_depth = depth(proj1, proj2)
			action_axis = axis

#	smallest_depth
#	action_axis

	get_tree().paused = true

	print(OS.get_time(), " Kolizcja, axes: ", action_axis)

# wykrycie przekrycia
func overlap(proj1, proj2):
	return max(proj1.x, proj2.x) <= min(proj1.y, proj2.y)

# pobranie głebokość penetracji	
func depth(proj1, proj2):
	return min(proj1.y, proj2.y) - max(proj1.x, proj2.x)