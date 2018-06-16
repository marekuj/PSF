
extends Camera

var camera_position           = Vector3(0,0,0)
var camera_target             = Vector3(0,0,0)
var camera_up_vector          = Vector3(0,1,0)

var camera_distance_to_center = 18

var yaw         = 0
var pitch       = PI/6.0

var sensitivity = 0.002
var scoll_speed = 2
var moveY = Vector3(0.0,1.0,0.0)
var moveX = Vector3(1.0,0.0,0.0)

func _ready():
	set_process_input(true)
	set_as_toplevel(true)
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )

func _process(delta):
	var x = camera_distance_to_center * sin(yaw) * cos(pitch)
	var y = camera_distance_to_center * sin(pitch)
	var z = camera_distance_to_center * cos(yaw) * cos(pitch)
	look_at_from_position( Vector3 ( x, y, z ), camera_target, camera_up_vector )
	

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	if event is InputEventMouseMotion:
		yaw     += event.relative.x * sensitivity
		pitch    = clamp ( pitch + event.relative.y * sensitivity,-1.5,1.5)
		
	if event is InputEventMouseButton:
		if (event.pressed and event.button_index == 4):
			camera_distance_to_center = clamp( camera_distance_to_center - scoll_speed, 4, 400)

		if (event.pressed and event.button_index == 5):
			camera_distance_to_center = clamp( camera_distance_to_center + scoll_speed, 4, 400)
