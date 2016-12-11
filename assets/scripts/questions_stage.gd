extends "res://assets/scripts/stage.gd"

onready var crosshair = get_tree().get_root().get_node( "main/crosshair" )

const MAX_PAGES_NUMBER = 5

var answered = false

func load_data():
	.load_data()
	Globals.set( "score_" + get_name(), 0 )

func select():
	if active:
		var content_text = pages_panel.get_node( "content/text" )
		if pages_panel.complete:
			content_text.set_text( "Você já respondeu a esse questionário" )
			content_button.disconnect( "pressed", self, "_on_content_button_pressed" )
		else:
			content_text.set_text( STAGES_INFO[ get_name() ] )
	.select()

func start():
	.start()
	pages_panel.start( MAX_PAGES_NUMBER, true )

func activate():
	if pages_panel.complete: crosshair.set_modulate( Color( 0, 0, 1, 1 ) )
	else: crosshair.set_modulate( Color( 0, 1, 0, 1 ) )
	.activate()

func deactivate():
	crosshair.set_modulate( Color( 1, 1, 1, 1 ) )
	.deactivate()
	if pages_panel.complete and not answered: 
		Globals.set( "score_" + get_name(), pages_panel.score )
		var total_score = Globals.get( "score" )
		total_score += Globals.get( "score_" + get_name() )
		Globals.set( "score", total_score )
		var completed_stages = Globals.get( "completed_stages" )
		Globals.set( "completed_stages", completed_stages + 1 )
		answered = true