extends "res://assets/scripts/stage.gd"

onready var crosshair = get_tree().get_root().get_node( "main/crosshair" )

func _ready():
	content_button.set_text( "Conteúdo" )

func start():
	.start()
	pages_panel.start( -1, false )

func activate():
	crosshair.set_modulate( Color( 1, 1, 0, 1 ) )
	.activate()

func deactivate():
	crosshair.set_modulate( Color( 1, 1, 1, 1 ) )
	.deactivate()

func select():
	if active:
		var completed_stages = Globals.get( "completed_stages" )
		var content_text = ""
		if completed_stages >= 5:
			content_text += "Você completou os testes !!\n\nPontuação Final:"
			for stage in STAGES_INFO:
				content_text += "\n" + STAGES_INFO[ stage ] + ": " + str( Globals.get( "score_" + stage ) )
			register_score()
			cancel_button.queue_free()
			content_button.disconnect( "pressed", self, "_on_content_button_pressed" )
			content_button.set_text( "Encerrar" )
			content_button.connect( "pressed", self, "quit_game" )
		else:
			content_text += "Seja bem-vindo !! Estamos ansiosos pela sua contribuição .\n\n"
			content_text += "Nossa empresa é composta por por 5 setores, sendo estes A, B, C, D  e E .\n"
			content_text += "Responda aos questionários de cada setor e retorne aqui para verificar sua pontuação.\n"
			content_text += "Você também pode retornar a qualquer momento para consultar o conteúdo de apoio."
		pages_panel.get_node( "content/text" ).set_text( content_text )
	.select()

func register_score():
	var player_name = "'" + Globals.get( "player_name" ) + "'"
	var final_score = Globals.get( "score" )
	var database = PSQLDatabase.new()
	database.connect_server( Globals.get( "server_host" ), "gamedb", "postgres", "postgres" )
	var registered_entries = database.select( "public.score", "*" )
	var player_entries = database.select( "public.score", "id,player", "WHERE player=" + player_name )
	if player_entries.size() > 0: database.update( "public.score", "points", str(final_score), "WHERE id=" + str(player_entries[ 0 ][ 'id' ]) )
	else: database.insert( "public.score", "id,player,points", str(registered_entries.size() + 1) + "," + player_name + "," + str(final_score) )

func quit_game():
	get_tree().call_deferred( "quit" )