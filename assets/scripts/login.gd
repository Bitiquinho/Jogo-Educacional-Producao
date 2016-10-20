extends Panel

onready var server_entry = get_node( "server_entry" )

var server_host = "localhost"
var player_name = null

func _ready():
	Globals.set( "score", 0 )
	if Globals.has( "server_host" ): server_host = Globals.get( "server_host" )
	server_entry.set_text( server_host )
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
	get_tree().set_pause( true )

func record_name( name ):
	player_name = name
	Globals.set( "player_name", player_name )
	print( "recording name " + name )

func register_data():
	var database = PSQLDatabase.new()
	database.connect_server( server_host, "gamedb", "postgres", "postgres" )
	var registered_players = database.select( "public.score", "player" )
	print( registered_players )
	database.update( "public.score", "points", "20", "WHERE id = 1" )
	#database.insert( "public.score", "player,points", insertion )
	#lobals.set_persisting( "server_host", true )
	Globals.save()

func start_game():
	register_data()
	print( "starting game" )
	get_tree().set_pause( false )
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
	hide()

func _on_server_entry_text_entered( text ):
	server_host = text
	Globals.set( "server_host", server_host )

func _on_login_entry_text_entered( text ):
	record_name( text )

func _on_start_button_pressed():
	if player_name != null: start_game()