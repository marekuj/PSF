extends Node

var Nds = []  # węzły
var NUM = 1
var e = 0.0 # wsp. restytucji

var node_object = load("material_point.tscn")
onready var node_mass = $mass
onready var node_clapper = $clapper

# *******************************************************************************************	
onready var sound1 = $sound1
onready var sound2 = $sound2

var show_force = true
var show_velocity = true

func toggle_show_velocity():
	show_velocity = !show_velocity
	for pt in Nds:
		pt.show_velocity(show_velocity) 

func toggle_show_force():
	show_force = !show_force
	for pt in Nds:
		pt.show_force(show_force) 
# *******************************************************************************************	

func _ready():
	create_scene()
	for pt in Nds:
		pt.show_force(show_force) 
		pt.show_velocity(show_velocity) 
		pt.sound=sound1

func _process(delta):
	pass

func _physics_process(delta):
	for i in range(Nds.size()):
		for j in range(i):
			var dist = (Nds[i].position - Nds[j].position)
			if(dist.length() < 2* Nds[i].radius() + Nds[j].radius()):
				print("Collision of pts: ",i," and ",j)
				var n = dist.normalized()
				var vI = Nds[i].velocity
				var vJ = Nds[j].velocity
				var mI = Nds[i].mass
				var mJ = Nds[j].mass
				var vIn = vI.dot(n)
				var vJn = vJ.dot(n)
				var Jdmm = (e + 1)*(vJn-vIn)/(mI+mJ)
				Nds[i].velocity +=  Jdmm*mJ*n - vIn*n
				Nds[j].velocity += -Jdmm*mI*n - vJn*n
				Nds[i].euler(delta)
				Nds[j].euler(delta)
				sound2.play(0)

func _input(event):	
	if event is InputEventKey:
		if event.is_action_pressed("ui_toggle_velocity"):
			toggle_show_velocity()
		if event.is_action_pressed("ui_toggle_force"):
			toggle_show_force()


func create_scene():
	# initialize points
	for i in range(NUM):
		var new_node  = node_object.instance()
		var r     = 3.5
		var phi   = 2*PI*randf()
		var theta = -0.5*PI + PI*randf()
		new_node.position = r*Vector3(cos(phi)*sin(theta),0,sin(phi)*sin(theta))
		new_node.node_mass = node_mass
		new_node.node_clapper = node_clapper
		new_node.set_mass(5)
		Nds.push_back(new_node)
		add_child(new_node)		
