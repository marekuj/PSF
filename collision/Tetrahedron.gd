extends ImmediateGeometry

# zmienne do symulacji ruchu postępowego
var prev_position   = Vector3(0.0,0.0,0.0)
var position        = Vector3(0.0,0.0,0.0)
var next_position   = Vector3(0.0,0.0,0.0)
export var velocity = Vector3(0.0,0.0,0.0)
var next_velocity   = Vector3(0.0,0.0,0.0)

# zmienne do symulacji ruchu obrotowego
export var angular_velocity      = Vector3(1.0,0.0,0.0)
var next_angular_velocity        = Vector3(0,0,0)
var rotation_representation      = Quat(Vector3(0.6,0.8,0.0),0.123)
var next_rotation_representation = Quat(0,0,0,1)

# *******************************************************************************************	
const PT_MASS = 0.25

const PT_SIZE = 1.0
var PT_1 = Vector3( 1.0*PT_SIZE, 1.0*PT_SIZE, 1.0*PT_SIZE)
var PT_2 = Vector3(-1.0*PT_SIZE,-1.0*PT_SIZE, 1.0*PT_SIZE)
var PT_3 = Vector3(-1.0*PT_SIZE, 1.0*PT_SIZE,-1.0*PT_SIZE)
var PT_4 = Vector3( 1.0*PT_SIZE,-1.0*PT_SIZE,-1.0*PT_SIZE)

const IDX_NORMAL  = 0
const IDX_COLOR   = 1
const IDX_POINT_1 = 2
const IDX_POINT_2 = 3
const IDX_POINT_3 = 4
const IDX_POINT_T = 5

const IDX_PT_POINT = 0
const IDX_PT_MASS  = 1

var triangles = []	# trójkaty 
var points    = []	# punkty
var edges     = []	# krawędzie
var mass   = null	# masa bryły sztywnej
var mu     = null	# odwrotność masy bryły sztywnej
var Xcm    = null	# środek masy bryły sztywnej 
var I	   = null	# tensor momentu bezwłdności 
var invI   = null   # odwrotność tensora

func make():
	triangles.append(createTriangle(PT_1, PT_2, PT_3, Color(1.0, 0.0, 0.0, 0.6)))
	triangles.append(createTriangle(PT_1, PT_4, PT_2, Color(0.0, 1.0, 0.0, 0.6)))
	triangles.append(createTriangle(PT_1, PT_3, PT_4, Color(1.0, 1.0, 0.0, 0.6)))
	triangles.append(createTriangle(PT_3, PT_2, PT_4, Color(1.0, 0.0, 1.0, 0.6)))

	points.append(createPoint(PT_1, PT_MASS))
	points.append(createPoint(PT_2, PT_MASS))
	points.append(createPoint(PT_3, PT_MASS))
	points.append(createPoint(PT_4, PT_MASS))

	edges.append(createEdge(PT_1, PT_2))
	edges.append(createEdge(PT_1, PT_3))
	edges.append(createEdge(PT_1, PT_4))
	edges.append(createEdge(PT_2, PT_3))
	edges.append(createEdge(PT_2, PT_4))
	edges.append(createEdge(PT_3, PT_4))

func createTriangle(v1, v2, v3, c):
	var n = (v3 - v2).cross(v1 - v2).normalized()
	var t = (v1 + v2 + v3)/3 
	return [n, c, v1, v2, v3, t]

func createPoint(v, m):
	return [v, m]	

func createEdge(v1, v2):
	return (v1 - v2).normalized()

func calc_mass():
	mass = 0.0
	Xcm = Vector3(0.0, 0.0, 0.0)
	for point in points:
		var p = point[IDX_PT_POINT]
		var m = point[IDX_PT_MASS]
		mass += m
		Xcm += m * p

	mu = 1.0 / mass
	Xcm /= mass

func calc_tensor():
	var ixx = 0.0
	var iyy = 0.0
	var izz = 0.0

	var ixy = 0.0
	var iyz = 0.0
	var izx = 0.0

	for point in points:
		var p = point[IDX_PT_POINT]
		var m = point[IDX_PT_MASS]
		ixx += m * (p.y * p.y + p.z * p.z)
		iyy += m * (p.z * p.z + p.x * p.x)
		izz += m * (p.x * p.x + p.y * p.y)
		ixy -= m * p.x * p.y
		iyz -= m * p.y * p.z
		izx -= m * p.z * p.x

	I = Basis(Vector3(ixx, ixy, izx), Vector3(ixy, iyy, iyz), Vector3(izx, iyz, izz))
	invI = I.inverse()

func _ready():
	make()
	calc_mass()
	calc_tensor()

	begin(VisualServer.PRIMITIVE_TRIANGLES)
	for triangle in triangles:
		#print("Normal: ", triangle[IDX_NORMAL])
		set_color(triangle[IDX_COLOR]) 
		set_normal(triangle[IDX_NORMAL])
		add_vertex(triangle[IDX_POINT_1]) 
		add_vertex(triangle[IDX_POINT_2]) 
		add_vertex(triangle[IDX_POINT_3]) 
	end()

	print("******************************************************************")
	print("* Masa:        ", mass)
	print("* Środek masy: ", Xcm)	
	print("* Tensor:      ", I)
	print("******************************************************************")

	position = translation
	prev_position = position - velocity * get_physics_process_delta_time()
	
func getAxes():
	var axes = []

	for triangle in triangles:
		axes.append( get_transform().basis * triangle[IDX_NORMAL] )	

#	var A = Vector3(1, 2, 3)
#	var B = get_transform().basis*A
#	print("* A1:      ", get_transform().basis.xform(A))
#	print("* A2:      ", get_transform().basis*A)
#	print("* A2:      ", get_transform().basis.xform_inv(B))	
#	print("* A3:      ", get_transform()) 
	return axes

func getEdges():
	var rib = []

	for edge in edges:
		rib.append( get_transform().basis * edge )	

	return rib

func getProjection(axes):
	var min_proj = axes.dot( get_transform() * PT_1 )
	var max_proj = axes.dot( get_transform() * PT_1 )

	for point in points:
		var proj = axes.dot( get_transform() * point[IDX_PT_POINT] )
		if proj < min_proj:
			min_proj = proj
		elif proj > max_proj:
			max_proj = proj

	return Vector2(min_proj, max_proj)

# *******************************************************************************************	

func _physics_process(delta):
	verlet(delta) # wykonaj całkowanie
	accept(delta) # zakceptuj nowe zmienne

func _process(delta):
	self.transform = trans_from_quat(rotation_representation.normalized(), position)

# algorytm verleta
func verlet(delta, F = force(delta), M = torque(delta)):
	next_position = 2*position - prev_position + mu*F*pow(delta,2)
	next_velocity = (next_position - position)/delta

	next_angular_velocity = angular_velocity + invI * (M - angular_velocity.cross(I*angular_velocity)) * delta
	next_rotation_representation = rotation_representation + quaternionize(next_angular_velocity) * 0.5 * rotation_representation * delta

# zmod. algorytm eulera
func euler(delta, F = force(delta), M = torque(delta)):	
	next_velocity = velocity + delta*mu*F
	next_position = position + delta*next_velocity

	next_angular_velocity = angular_velocity + invI * (M - angular_velocity.cross(I*angular_velocity)) * delta
	next_rotation_representation = rotation_representation + quaternionize(next_angular_velocity) * 0.5 * rotation_representation * delta	

# akceptacja ruchu
func accept(delta):
	prev_position = position
	position = next_position
	velocity = next_velocity
	angular_velocity = next_angular_velocity
	rotation_representation = next_rotation_representation

# moment siły
func torque(delta):
	return Vector3(0.0,0.0,0.0)#-0.1*angular_velocity

# siła
func force(delta):
	return -0.1*position-0.1*velocity # naiwna siła sprężystości

# wektor w kwaternion
func quaternionize(vec):
	return Quat(vec.x,vec.y,vec.z,0)

# kwaternion w wektor
func dequaternionize(quat):
	return Vector3(quat.x,quat.y,quat.z)

# kwaternion w transformację
func trans_from_quat(Q, P):
	var i = Vector3(1.0 - 2*(pow(Q.y,2) + pow(Q.z,2)), 2*(Q.x*Q.y + Q.z*Q.w), 2*(Q.x*Q.z - Q.y*Q.w))
	var j = Vector3(2*(Q.x*Q.y - Q.z*Q.w), 1.0 - 2*(pow(Q.z,2) + pow(Q.x,2)), 2*(Q.y*Q.z + Q.x*Q.w))
	var k = Vector3(2*(Q.x*Q.z + Q.y*Q.w), 2*(Q.y*Q.z - Q.x*Q.w), 1.0 - 2*(pow(Q.x,2) + pow(Q.y,2)))
	return Transform(i,j,k, P)