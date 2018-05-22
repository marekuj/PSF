extends MeshInstance

var position = Vector3(0.0, 0.0, 0.0)
var radius = 1

func _ready():
	# SphereMesh creates a sphere in (0.0,0.0,0.0) with radius = 1.0
	# self.scale_object_local(Vector3(radius,radius,radius))
	# self.translate(position/radius)
	
	radius = get_scale().x;
	position = get_translation();
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.button_mask == BUTTON_MASK_LEFT:
		var dist = camera.get_translation().distance_to(get_translation())
		var click_in_camera = camera.to_local(click_position)
		position = camera.to_global(click_in_camera.normalized() * dist)
		set_translation(position)
