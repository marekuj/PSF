extends Node

var position
var velocity          = Vector3( 0.0, 0.0, 0.0 )
var previous_position = Vector3( 0.0, 0.0, 0.0 )
var gravity           = Vector3( 0.0, 0.0, 0.0 )
var viscosity         = Vector3( 0.0, 0.0, 0.0 )
var zero_tolerance    = 0.00001

var mass      = 1.0
var mu        = 1.0 # 1./mass

var node_mass = null
var node_clapper = null

var is_static = false
onready var point_v = $"point_v"
onready var arrow_v = $"point_v/arrow"
onready var arrowhead_v  = $"point_v/arrowhead"
var up_v = Vector3(0.0,1.0,0.0)
onready var point_f = $"point_f"
onready var arrow_f = $"point_f/arrow"
onready var arrowhead_f  = $"point_f/arrowhead"
var up_f = Vector3(0.0,1.0,0.0)

# *******************************************************************************************
var new_velocity = Vector3(0.0, 0.0, 0.0)
var new_force = Vector3(0.0, 0.0, 0.0)

onready var sound = null
var force = Vector3(0.0, 0.0, 0.0)
var PROJ = 0
var PERP = 1

# współczynnik sprężystości [0..1]
var elasticity_factor = 0.8

# współczynnik tarcia dynamicznego
var friction_factor = 0.4

# projekcja wektora W na V
func proj_perp (W, V):
	var proj = W.dot(V) * V
	var perp = W - proj	
	return [proj, perp]

# wyznacz przyspieszenie po odbiciu
func new_velocity(v, n, e = elasticity_factor):
	var v_pp = proj_perp(v, n)		
	return v_pp[PERP] - e * v_pp[PROJ]

# wyznacz siłę po odbiciu	
func new_force(f, n, v, u = friction_factor):		
	var f_pp = proj_perp(f, n)	
	var v_pp = proj_perp(v, n)	
	var r = -f_pp[PROJ] 
	var t = -u * f_pp[PROJ] * v_pp[PROJ].normalized()
	
	return f + r + t
	
func show_velocity(show):
	if arrow_v:
		arrow_v.set_visible(show) 	
	if arrowhead_v:
		arrowhead_v.set_visible(show) 	
	
func show_force(show):
	if arrow_f:
		arrow_f.set_visible(show) 	
	if arrowhead_f:
		arrowhead_f.set_visible(show) 	
# *******************************************************************************************	

func _ready():
	# setting velocity
	velocity = 0.01*Vector3(2*randf()-1.0,randf(),2*randf()-1.0)
	
	# setting positions
	previous_position = position - velocity * get_physics_process_delta_time()
	point_v.global_translate(position)
	point_f.global_translate(position)

	# setting color
	var mat = SpatialMaterial.new()
	mat.albedo_color = Color(randf(), randf(), randf())
	mat.set_metallic(0.0)
	mat.set_specular(0.0)
	point_v.set_surface_material(0,mat)

	var mat_v = SpatialMaterial.new()
	mat_v.albedo_color = Color(1.0, 1.0, 0.0)
	mat_v.set_metallic(0.5)
	mat_v.set_specular(0.5)
	arrow_v.set_surface_material(0, mat_v)
	arrowhead_v.set_surface_material(0, mat_v)

	var mat_f = SpatialMaterial.new()
	mat_f.albedo_color = Color(1.0, 0.0, 0.0)
	mat_f.set_metallic(0.5)
	mat_f.set_specular(0.5)
	arrow_f.set_surface_material(0, mat_f)
	arrowhead_f.set_surface_material(0, mat_f)

func _physics_process(delta):
	if !is_static:
		newton(delta)
		verlet(delta)
		collision(delta, node_mass)
		collision(delta, node_clapper)

func _process(delta):
	if !is_static:
		point_v.translation = position
		arrow_v.scale = Vector3(0.2,5.0*velocity.length(),0.2)
		arrow_v.translation = Vector3(0.0,5.0*velocity.length(),0.0)
		arrowhead_v.translation = Vector3(0.0,10.0*velocity.length(),0.0)

		var axis_v = up_v.cross(velocity.normalized())
		var angle_v = acos(up_v.dot(velocity.normalized()))
		if axis_v.length() > 1e-3:
			point_v.global_rotate(axis_v.normalized(), angle_v)
		up_v = velocity.normalized()
		
		point_f.translation = position
		arrow_f.scale = Vector3(0.2,5.0*force.length(),0.2)
		arrow_f.translation = Vector3(0.0,5.0*force.length(),0.0)
		arrowhead_f.translation = Vector3(0.0,10.0*force.length(),0.0)

		var axis_f = up_f.cross(force.normalized())
		var angle_f = acos(up_f.dot(force.normalized()))
		if axis_f.length() > 1e-3:
			point_f.global_rotate(axis_f.normalized(), angle_f)
		up_f = force.normalized()


func set_velocity(v):
	velocity          = v
	previous_position = position - velocity * get_physics_process_delta_time()


func set_mass(m):
	mass = m
	mu   = pow( m, -1.0 )


func collision(delta, collider, hit_delta = 0.1):
	var hit = collider.collision(self, hit_delta)
	if hit:
		velocity = new_velocity
		force = new_force
		if previous_position.distance_to(position) > 0.01:
			sound.play(0)
		euler(delta)

func euler(delta):
	velocity += force * mu * delta
	previous_position = position
	position += velocity * delta


func verlet(delta):
	var new_position  = 2 * position - previous_position + force * mu * pow( delta , 2.0 )
	previous_position = position
	position          = new_position
	velocity          = ( position - previous_position ) / delta


func newton(delta):
	var distance = position - node_mass.position
	gravity = Vector3(0,0,0)
	if distance.length() > 0.01:
		gravity = -self.mass * distance * pow(distance.length(), -2)
		viscosity = -0.5 * self.velocity
#	if distance.length() > 10:
#		if distance.dot(velocity) > 0:
#			viscosity *= 2
#		else:
#			gravity *= 10
	force = gravity + viscosity


func radius():
	return self.get_physics_process_delta_time() * self.velocity.length() + zero_tolerance
