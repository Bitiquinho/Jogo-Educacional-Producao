extends Panel

func _ready():
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

func _on_login_entry_text_entered( text ):
	record_name( text )

func _on_start_button_pressed():
	start_game()
