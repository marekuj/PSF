extends ImmediateGeometry

# *******************************************************************************************	
var position = Vector3(0.0, 0.0, 0.0)
var drag = false
var camera = null

var PT_SIZE = 2.0
var PT_1 = Vector3(-1.0*PT_SIZE,-0.7*PT_SIZE, 1.0*PT_SIZE)
var PT_2 = Vector3(-1.0*PT_SIZE, 1.0*PT_SIZE, 0.8*PT_SIZE)
var PT_3 = Vector3( 0.9*PT_SIZE, 0.8*PT_SIZE, 1.0*PT_SIZE)
var PT_4 = Vector3( 1.0*PT_SIZE,-1.0*PT_SIZE, 1.0*PT_SIZE)
var PT_5 = Vector3( 0.8*PT_SIZE, 0.6*PT_SIZE,-0.7*PT_SIZE)
var PT_6 = Vector3(-0.9*PT_SIZE,-1.0*PT_SIZE,-1.0*PT_SIZE)
var PT_7 = Vector3( 1.0*PT_SIZE,-0.7*PT_SIZE,-1.0*PT_SIZE)
var PT_8 = Vector3(-0.8*PT_SIZE, 1.0*PT_SIZE,-1.0*PT_SIZE)

var IDX_NORMAL  = 0
var IDX_COLOR   = 1
var IDX_POINT_1 = 2
var IDX_POINT_2 = 3
var IDX_POINT_3 = 4
var IDX_POINT_T = 5

var triangles = []  # punkty

func make():
	triangles.append(createTriangle(PT_1, PT_2, PT_3))
	triangles.append(createTriangle(PT_1, PT_3, PT_4))

	triangles.append(createTriangle(PT_1, PT_6, PT_2))
	triangles.append(createTriangle(PT_2, PT_6, PT_8))

	triangles.append(createTriangle(PT_3, PT_5, PT_7))
	triangles.append(createTriangle(PT_4, PT_3, PT_7))

	triangles.append(createTriangle(PT_5, PT_6, PT_7))
	triangles.append(createTriangle(PT_5, PT_8, PT_6))

	triangles.append(createTriangle(PT_2, PT_5, PT_3))
	triangles.append(createTriangle(PT_5, PT_2, PT_8))

	triangles.append(createTriangle(PT_1, PT_4, PT_6))
	triangles.append(createTriangle(PT_6, PT_4, PT_7))


func createTriangle(v1, v2, v3):
	var n = (v3 - v2).cross(v1 - v2).normalized()
#	var c = Color(1.0, 0.0, 0.0, 0.0)
	var c = Color(abs(n.x), abs(n.y), abs(n.z), 0.6)	
	var t = (v1 + v2 + v3)/3 
	return [n, c, v1, v2, v3, t]
	
func collision(pt, hit_delta = 0.2):
	pt.new_velocity = Vector3(0.0, 0.0, 0.0)
	pt.new_force = Vector3(0.0, 0.0, 0.0)	
	var hit = false
	var P1 = to_local(pt.previous_position)
	var P2 = to_local(pt.position)
	for triangle in triangles:
		var T = triangle[IDX_POINT_T]
		var n = triangle[IDX_NORMAL]
		if n.dot(P1-T) < hit_delta:
			if n.dot(P1 - P2) == 0:
				continue
			var t = n.dot(P1 - T) / n.dot(P1 - P2)
			var P = (1 -t) * P1 + t * P2
			#print("Kolizja ", n.dot(P1-T)," w punkcie: ",  P)
			var T1 = triangle[IDX_POINT_1]	
			var T2 = triangle[IDX_POINT_2]	
			var T3 = triangle[IDX_POINT_3]	
			if (T2 - T1).cross(P - T1).dot(n) >= 0 and (T3 - T2).cross(P - T2).dot(n) >= 0 and (T1 - T3).cross(P - T3).dot(n) >= 0:
				pt.new_velocity += pt.new_velocity(pt.velocity, n)
				pt.new_force += pt.new_force(pt.force, n, pt.velocity)
				#print("Trafienie: ", triangle)
				hit = true
	return hit
# *******************************************************************************************	


func _ready():
	position = get_translation();
	camera = get_parent().get_parent().get_node("Camera")

	make()

	begin(VisualServer.PRIMITIVE_TRIANGLES)
	for triangle in triangles:
		print("Normal: ", triangle[IDX_NORMAL])
		set_color(triangle[IDX_COLOR]) 
		set_normal(triangle[IDX_NORMAL])
		add_vertex(get_translation() + triangle[IDX_POINT_1]) 
		add_vertex(get_translation() + triangle[IDX_POINT_2]) 
		add_vertex(get_translation() + triangle[IDX_POINT_3]) 
	end()	

func _physics_process(delta):
	if drag && camera:
		var mouse_pos = get_viewport().get_mouse_position()
		var click_position = camera.project_position(mouse_pos)		
		var dist = camera.get_translation().distance_to(get_translation())
		var click_in_camera = camera.to_local(click_position)
		position = camera.to_global(click_in_camera.normalized() * dist)
		set_translation(position)

func _on_Camera_stop_drag():
	drag = false	


func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:		
		if (event.pressed and event.button_index == BUTTON_LEFT):
				drag = true