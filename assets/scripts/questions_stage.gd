extends "res://assets/scripts/stage.gd"

const MAX_PAGES_NUMBER = 5

var answered = false

func _ready():
	pass

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

func deactivate():
	.deactivate()
	if pages_panel.complete and not answered: 
		Globals.set( "score_" + get_name(), pages_panel.score )
		var total_score = Globals.get( "score" )
		total_score += Globals.get( "score_" + get_name() )
		Globals.set( "score", total_score )
		var complete_stages = Globals.get( "complete_stages" )
		Globals.set( "complete_stages", complete_stages + 1 )
		answered = true