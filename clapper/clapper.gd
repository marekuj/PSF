extends MeshInstance

var position = Vector3(0.0, 0.0, 0.0)
var radius = 1

# *******************************************************************************************
var drag = false
var camera = null
var Nds = []  # węzły

func collision(pt, hit_delta = 0.1):
	var dist = pt.position - position	
	if abs(dist.length() - (pt.radius() + radius)) < hit_delta:
		return dist.normalized()
	return null
# *******************************************************************************************
func _ready():
	radius = get_scale().x;
	position = get_translation();
	camera = get_parent().get_parent().get_node("Camera")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _physics_process(delta):
	if drag && camera:
		var mouse_pos = get_viewport().get_mouse_position()
		var click_position = camera.project_position(mouse_pos)
		var dist = camera.get_translation().distance_to(get_translation())
		var click_in_camera = camera.to_local(click_position)
		position = camera.to_global(click_in_camera.normalized() * dist)
		set_translation(position)
#		for pt in Nds:
#			var normal = collision(pt)
#			if normal != null and pt.is_static:
#				pt.position = 
#				pt
#			pt._physics_process(delta)	

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if (event.pressed and event.button_index == BUTTON_LEFT):
				drag = true

func _on_Camera_stop_drag():
	drag = false
