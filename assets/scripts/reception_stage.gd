extends "res://assets/scripts/stage.gd"

func _ready():
	content_button.set_text( "Conteúdo" )
	#._ready()

func start():
	.start()
	pages_panel.start( -1, false )

func select():
	if active:
		var complete_stages = Globals.get( "complete_stages" )
		var content_text = ""
		if complete_stages >= 5:
			content_text += "Você completou os testes !!\n\nPontuação Final:"
			for stage in STAGES_INFO:
				content_text += "\n" + STAGES_INFO[ stage ] + ": " + str( Globals.get( "score_" + stage ) )
			cancel_button.queue_free()
			content_button.disconnect( "pressed", self, "_on_content_button_pressed" )
			content_button.set_text( "Encerrar" )
			content_button.connect( "pressed", self, "quit_game" )
		else:
			content_text += "Seja bem-vindo !! Estamos ansiosos pela sua contribuição������.\n\n"
			content_text += "Nossa empresa é composta por por 5 setores, sendo estes A, B, C, D  e E������.\n"
			content_text += "Responda aos questionários de cada setor e retorne aqui para verificar sua pontuação.\n"
			content_text += "Você também pode retornar a qualquer momento para consultar o conteúdo de apoio."
		pages_panel.get_node( "content/text" ).set_text( content_text )
	.select()

func quit_game():
	get_tree().call_deferred( "quit" )