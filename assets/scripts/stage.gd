extends Spatial

onready var pages_panel = get_node( "pages_panel" )

var active = false

func load_data():
	pages_panel.load_data( get_name() )

func activate():
	active = true

func deactivate():
	active = false
