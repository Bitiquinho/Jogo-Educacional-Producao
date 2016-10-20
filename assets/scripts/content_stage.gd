extends Spatial

var active = false

onready var pages_panel = get_node( "pages_panel" )

func _ready():
	pages_panel.load_data( get_name() )

func activate():
	active = true

func deactivate():
	active = false

func select():
	if active: pages_panel.start( -1, false )