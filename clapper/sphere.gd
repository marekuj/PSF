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
