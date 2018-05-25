extends ImmediateGeometry

# *******************************************************************************************	
var PT_1 = Vector3(-1.0,-1.0, 1.0)
var PT_2 = Vector3(-1.0, 1.0, 1.0)
var PT_3 = Vector3( 1.0, 1.0, 1.0)
var PT_4 = Vector3( 1.0,-1.0, 1.0)


var PT_5 = Vector3( 1.0, 1.0,-1.0)
var PT_6 = Vector3(-1.0,-1.0,-1.0)
var PT_7 = Vector3( 1.0,-1.0,-1.0)
var PT_8 = Vector3(-1.0, 1.0,-1.0)

var IDX_NORMAL  = 0
var IDX_COLOR   = 1
var IDX_POINT_1 = 2
var IDX_POINT_2 = 3
var IDX_POINT_3 = 4

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
	
	return [n, c, v1, v2, v3]
# *******************************************************************************************	
	
func _ready():
	make()
#	begin( VisualServer.PRIMITIVE_TRIANGLES, null )
#	for i in range(NUM-1):
#		for j in range(NUM-1):
#			# first triangle			
#			set_normal( (get_parent().Nds[NUM * (i+1) + j + 1 ].position-get_parent().Nds[NUM * (i+1) + j ].position).cross(get_parent().Nds[NUM * (i  ) + j ].position-get_parent().Nds[NUM * (i+1) + j ].position).normalized() )
#			set_uv( Vector2( float(i)/NUM, float(j)/NUM ) )
#			add_vertex( get_parent().Nds[NUM * (i  ) + j ].position )
#			set_uv( Vector2( float(i+1)/NUM, float(j+1)/NUM ) )
#			add_vertex( get_parent().Nds[NUM * (i+1) + j + 1 ].position )
#			set_uv( Vector2( float(i+1)/NUM, float(j)/NUM ) )
#			add_vertex( get_parent().Nds[NUM * (i+1) + j ].position )
#			# second triangle
#			set_normal( (get_parent().Nds[NUM * (i  ) + j ].position-get_parent().Nds[NUM * (i  ) + j + 1 ].position).cross(get_parent().Nds[NUM * (i+1) + j + 1 ].position-get_parent().Nds[NUM * (i  ) + j + 1 ].position).normalized() )
#			set_uv( Vector2( float(i)/NUM, float(j)/NUM ) )
#			add_vertex( get_parent().Nds[NUM * (i  ) + j ].position )
#			set_uv( Vector2( float(i)/NUM, float(j+1)/NUM ) )
#			add_vertex( get_parent().Nds[NUM * (i  ) + j + 1 ].position )
#			set_uv( Vector2( float(i+1)/NUM, float(j+1)/NUM ) )
#			add_vertex( get_parent().Nds[NUM * (i+1) + j + 1 ].position )
#	end()
	
	begin(VisualServer.PRIMITIVE_TRIANGLES)
	for triangle in triangles:
		print(triangle[IDX_NORMAL])
		set_color(triangle[IDX_COLOR]) 
		set_normal(triangle[IDX_NORMAL])
		add_vertex(get_translation() + triangle[IDX_POINT_1]) 
		add_vertex(get_translation() + triangle[IDX_POINT_2]) 
		add_vertex(get_translation() + triangle[IDX_POINT_3]) 
	end()	
		
#	begin(VisualServer.PRIMITIVE_TRIANGLES)
#
#	set_color(Color(1,0,0))
#	add_vertex(get_translation() + Vector3(-1.0,-1.0, 1.0)) 
#	add_vertex(get_translation() + Vector3(-1.0, 1.0, 1.0)) 
#	add_vertex(get_translation() + Vector3(-1.0,-1.0,-1.0)) 
#
#	set_color(Color(1,1,0))
#	add_vertex(get_translation() + Vector3(-2.0,-1.0, 1.0)) 
#	add_vertex(get_translation() + Vector3(-2.0, 1.0, 1.0)) 
#	add_vertex(get_translation() + Vector3(-2.0,-1.0,-1.0)) 
#	end()	

func _physics_process(delta):
#	print("tomne")
	pass
