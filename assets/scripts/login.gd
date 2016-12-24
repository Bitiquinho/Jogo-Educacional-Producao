extends Panel

onready var server_entry = get_node( "server_entry" )
onready var login_entry = get_node( "login_entry" )

func _ready():
	if not Globals.has( "server_host" ): Globals.set( "server_host", "localhost" )
	if not Globals.has( "player_name" ): Globals.set( "player_name", "" )
	Globals.set_persisting( "server_host", true )
	Globals.set_persisting( "player_name", true )
	server_entry.set_text( Globals.get( "server_host" ) )
	login_entry.set_text( Globals.get( "player_name" ) )
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
	get_tree().set_pause( true )

func start_game():
	Globals.save()
	for stage in Game.stages: stage.load_data()
	print( "starting game" )
	get_tree().set_pause( false )
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
	hide()

func _on_server_entry_text_entered( text ):
	Globals.set( "server_host", text )

func _on_login_entry_text_entered( text ):
	Globals.set( "player_name", text )

func _on_start_button_pressed():
	Globals.set( "player_name", login_entry.get_text() )
	if not Globals.get( "player_name" ).empty(): start_game()