extends Node

const IDX_VERTEX_EDGE  = 1
const IDX_EDGE_VERTEX  = 2
const IDX_EDGE_EDGE    = 3


func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	for node1 in get_children():
		for node2 in get_children():
			if node1 > node2:
				check_sat(node1, node2, delta)


func check_sat(node1, node2, delta):
# sat 
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

# punkt styku
	var contact1 = node1.getContactPoint(action_axis)
	var contact2 = node2.getContactPoint(action_axis)

# kolizja 
	var n = action_axis
	var r1 = contact1 - node1.position
	var r2 = contact2 - node2.position
	var J = impulse(node1, node2, action_axis, r1, r2 )

	node1.hit(J, r1, n, delta)
	node2.hit(-J, r2, n, delta)

#	get_tree().paused = true

# wykrycie przekrycia
func overlap(proj1, proj2):
	return max(proj1.x, proj2.x) <= min(proj1.y, proj2.y)

# pobranie głebokość penetracji	
func depth(proj1, proj2):
	return min(proj1.y, proj2.y) - max(proj1.x, proj2.x)

# wyliczenie popędu, 0.0 <= e <= 1.0	
func impulse(node1, node2, n, r1, r2, e = 1.0):
	var mass_factor = (node1.mass * node2.mass) / (node1.mass + node2.mass)
	var velocity_factor = node2.velocity - node1.velocity
	
	var down1 = (node1.invI  * r1.cross(n)).cross(r1)
	var down2 = (node2.invI  * r2.cross(n)).cross(r2)

	var up = mass_factor * velocity_factor.dot(n) * (e + 1)
	var down = 1 - mass_factor * (down1 + down2).dot(n)

	return up / down
