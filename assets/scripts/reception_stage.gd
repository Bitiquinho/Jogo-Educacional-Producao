extends "res://assets/scripts/stage.gd"

onready var next_button = pages_panel.get_node( "next_button" )

func load_data():
	var pages_text = [ 
	                   "Seja bem-vindo !! Estamos ansiosos pela sua contribuição .\n\n" \
	                   + "Nossa empresa é composta por por 5 setores, sendo estes A, B, C, D  e E .\n" \
	                   + "Responda aos questionários de cada setor e retorne aqui para verificar sua pontuação.\n" \
	                   + "Você também pode retornar a qualquer momento para consultar o conteúdo de apoio.",
	                   "Os setores de questionários são:\n"
	                 ] 
	var stage_names = Game.STAGES_INFO.keys()
	stage_names.sort()
	for stage in stage_names:
		pages_text[ 1 ] += "\n" + stage + ": " + Game.STAGES_INFO[ stage ][ 0 ] + " (peso: " + str(Game.STAGES_INFO[ stage ][ 1 ]) + ")" 
	for text_string in pages_text:
		pages_panel.pages_list.append( { "text": text_string, "options": "", "image": null } )
#	.load_data()

func activate():
	Game.crosshair.set_modulate( Color( 1, 1, 0, 1 ) )
	.activate()

func deactivate():
	Game.crosshair.set_modulate( Color( 1, 1, 1, 1 ) )
	.deactivate()

func select():
	if active:
		if Game.completed_stages >= Game.STAGES_INFO.size():
			pages_panel.pages_list[ 0 ][ "text" ] = "Você completou os testes !!\n\nPontuação Final:"
			for stage in Game.STAGES_INFO:
				pages_panel.pages_list[ 0 ][ "text" ] += "\n" + Game.STAGES_INFO[ stage ][ 0 ] + ": " + str( Game.stage_scores[ "score_" + stage ] )
			pages_panel.pages_list[ 0 ][ "text" ] += "\nTotal: " + str(Game.total_score)
			register_score()
			next_button.disconnect( "pressed", pages_panel, "_on_next_button_pressed" )
			next_button.connect( "pressed", self, "quit_game" )
			pages_panel.start( 1, false, 0 )
			next_button.set_text( "Encerrar" )
		else:
			pages_panel.start( -1, false, 0 )
		pages_panel.show_panel()

func register_score():
	var player_name = "'" + Globals.get( "player_name" ) + "'"
	var score_string = str(Game.total_score)
	var database = PSQLDatabase.new()
	database.connect_server( Globals.get( "server_host" ), "gamedb", "postgres", "postgres" )
	var registered_entries = database.select( "public.score", "*" )
	var player_entries = database.select( "public.score", "id,player", "WHERE player=" + player_name )
	if player_entries.size() > 0: database.update( "public.score", "points", score_string, "WHERE id=" + str(player_entries[ 0 ][ 'id' ]) )
	else: database.insert( "public.score", "id,player,points", str(registered_entries.size() + 1) + "," + player_name + "," + score_string )

func quit_game():
	get_tree().call_deferred( "quit" )
