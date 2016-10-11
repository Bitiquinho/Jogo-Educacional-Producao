extends Panel

onready var content_text = get_node( "content/text" )
onready var content_image = get_node( "content/image" )
onready var option_buttons = get_node( "option_buttons" )

var pages_list = []
const MAX_PAGES_NUMBER = 5
var current_pages_count = 0

var right_option = -1

func _input( event ):
	if event.type == InputEvent.KEY:
		if event.pressed and event.scancode == KEY_BACKSPACE:
			finish()

func start():
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
	get_tree().set_pause( true )
	show()
	set_process_input( true )
	current_pages_count = 0
	randomize()
	next_page()

func finish():
	hide()
	get_tree().set_pause( false )
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
	set_process_input( false )

func load_data( data_id ):
	pages_list.clear()
	var database = PSQLDatabase.new()
	database.connect_server( "localhost", "gamedb", "postgres", "postgres" )
	pages_list = database.select( "public.pages", "id,text,options,image", \
	                              "WHERE type = '" + data_id + "' ORDER BY id" )
	print( pages_list )
	var image_file = File.new()
	for page_idx in range( pages_list.size() ):
		if pages_list[ page_idx ].has( "image" ):
			var image_buffer = pages_list[ page_idx ][ "image" ]
			image_file.open( "cache.png", File.WRITE )
			image_file.store_buffer( image_buffer )
			image_file.close()
			pages_list[ page_idx ][ "image" ] = ImageTexture.new()
			pages_list[ page_idx ][ "image" ].load( "cache.png" )
		else:
			pages_list[ page_idx ][ "image" ] = null
		print( pages_list[ page_idx ] )

func next_page():
	current_pages_count += 1
	var pages_number = min( pages_list.size(), MAX_PAGES_NUMBER )
	if current_pages_count > pages_number: 
		finish()
		return
	var page_idx = current_pages_count - 1
	var page = pages_list[ page_idx ]
	print( page )
	content_text.set_text( page[ "text" ] )
	content_image.set_texture( page[ "image" ] )
	option_buttons.clear()
	right_option = -1
	var option_entries = page[ "options" ].split( ",", false )
	for entry_idx in range( option_entries.size() ):
		var entry = option_entries[ entry_idx ]
		if entry.find( "*" ) == 0: 
		  right_option= entry_idx
		  entry = entry.substr( 1, entry.length() - 1 )
		option_buttons.add_button( entry )

func _on_buttons_button_selected( button_idx ):
	print( "selected button " + str( button_idx ) + ": " + str( button_idx == right_option ) )

func _on_next_button_pressed():
	print( "next page" )
	next_page()
