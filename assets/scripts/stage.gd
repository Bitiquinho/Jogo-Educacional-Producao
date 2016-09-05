extends TestCube

onready var material = get_material_override()
onready var initial_color = material.get_parameter( FixedMaterial.PARAM_DIFFUSE )
var active = false

onready var question_panel = get_node( "question_panel" )

func activate():
	active = true
	material.set_parameter( FixedMaterial.PARAM_DIFFUSE, Color( 0, 1, 0 ) )

func deactivate():
	active = true
	material.set_parameter( FixedMaterial.PARAM_DIFFUSE, initial_color )

func select():
	if active: question_panel.start()