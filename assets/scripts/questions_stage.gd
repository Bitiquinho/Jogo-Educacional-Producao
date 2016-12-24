extends "res://assets/scripts/stage.gd"

const MAX_PAGES_NUMBER = 5

var answered = false

func load_data():
	pages_panel.pages_list.append( { "text": Game.STAGES_INFO[ get_name() ][ 0 ], "options": "", "image": null } )
	.load_data()
	Game.stage_scores[ "score_" + get_name() ] = 0

func select():
	if active:
		if pages_panel.complete:
			pages_panel.pages_list[ 0 ][ "text" ] = "Você já respondeu a esse questionário"
			pages_panel.start( 1, false, 0 )
		else:
			pages_panel.start( MAX_PAGES_NUMBER, true, Game.STAGES_INFO[ get_name() ][ 1 ] )
		pages_panel.show_panel()

func activate():
	if pages_panel.complete: Game.crosshair.set_modulate( Color( 0, 0, 1, 1 ) )
	else: Game.crosshair.set_modulate( Color( 0, 1, 0, 1 ) )
	.activate()

func deactivate():
	Game.crosshair.set_modulate( Color( 1, 1, 1, 1 ) )
	.deactivate()
	if pages_panel.complete and not answered: 
		Game.stage_scores[ "score_" + get_name() ] = pages_panel.score
		Game.total_score += Game.stage_scores[ "score_" + get_name() ]
		Game.completed_stages += 1
		answered = true