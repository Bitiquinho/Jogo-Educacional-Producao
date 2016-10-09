extends Panel

onready var content_text = get_node( "content/text" )
onready var option_buttons = get_node( "option_buttons" )

var pages_list = []
var current_page = 0

func _input( event ):
	if event.type == InputEvent.KEY:
		if event.pressed and event.scancode == KEY_BACKSPACE:
			finish()

func start():
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
	get_tree().set_pause( true )
	show()
	set_process_input( true )
	current_page = 0
	create_screen()

func finish():
	hide()
	get_tree().set_pause( false )
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
	set_process_input( false )

func load_data( data_id ):
	var database = PSQLDatabase.new()
	database.connect_server( "localhost", "gamedb", "postgres", "postgres" )
	var result = database.load_table( "information_schema.quiz" )
	print( result )
	var data_file = File.new()
	data_file.open( "res://assets/strings/" + data_id + ".json", File.READ )
	var data_string = data_file.get_as_text()
	var pages_dict = Dictionary()
	pages_dict.parse_json( data_string )
	pages_list = pages_dict[ "paginas" ]

func create_screen():
	if pages_list.size() > 0:
		var screen_dict = pages_list[ current_page ]
		print( screen_dict )
		content_text.set_text( screen_dict[ "texto" ] )
		option_buttons.clear()
		option_buttons.add_button( "resposta 1" )
		option_buttons.add_button( "resposta 2" )

func _on_buttons_button_selected( button_idx ):
	print( "selected button " + str( button_idx ) )
