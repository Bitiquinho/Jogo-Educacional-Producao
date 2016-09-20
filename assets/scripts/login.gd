extends Panel

func _ready():
	get_node( "login_entry" ).connect( "text_entered", self, "record_name" )
	get_node( "start_button" ).connect( "pressed", self, "start_game" )
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
	get_tree().set_pause( true )

func record_name( name ):
	var record_file = File.new()
	record_file.open( "res://assets/strings/recorded_names.txt", File.WRITE )
	record_file.store_string( name )
	print( "recording name " + name )

func start_game():
	print( "starting game" )
	get_tree().set_pause( false )
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
	hide()