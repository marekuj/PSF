extends Node

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	for node1 in get_children():
		for node2 in get_children():
			if node1 > node2:
				#TODO: Wykrywanie i fizyka zderzeń
				checkSAT(node1, node2)

func checkSAT(node1, node2):
	var axes1 = node1.getAxes()
	var axes2 = node2.getAxes()	
	var edges1 = node1.getEdges()
	var edges2 = node2.getEdges()

	for axis in axes1:
		var proj1 = node1.getProjection(axis)
		var proj2 = node2.getProjection(axis)
		if !overlap(proj1, proj2):
			return

	for axis in axes2:
		var proj1 = node1.getProjection(axis)
		var proj2 = node2.getProjection(axis)
		if !overlap(proj1, proj2):
			return

	for edge1 in edges1:
		for edge2 in edges2:
			var axis = edge1.cross(edge2)
			var proj1 = node1.getProjection(axis)
			var proj2 = node2.getProjection(axis)
			if !overlap(proj1, proj2):
				return
	 
	print(OS.get_time(), " Kolizcja !!!")

# wykrycie przekrycia
func overlap(proj1, proj2):
	return max(proj1.x, proj2.x) <= min(proj1.y, proj2.y)