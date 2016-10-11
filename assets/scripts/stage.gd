extends Spatial

var active = false

onready var question_panel = get_node( "question_panel" )

func _ready():
	question_panel.load_data( get_name() )

func activate():
	active = true

func deactivate():
	active = true

func select():
	if active: question_panel.start()