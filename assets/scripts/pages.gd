extends Panel

onready var content_text = get_node( "content/text" )
onready var content_image = get_node( "content/image" )
onready var option_buttons = get_node( "option_buttons" )

var pages_list = []
var loaded_pages_list = []
var current_pages_count = 0
var random = false

var score = 0
var right_option = -1

var complete = false

func show_panel():
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
	get_tree().set_pause( true )
	show()

func hide_panel():
	hide()
	get_tree().set_pause( false )
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )

func start( max_pages, random_pages ):
	show_panel()
	if random_pages: 
		randomize()
		var pages_number = min( max_pages, loaded_pages_list.size() )
		for page_idx in range( pages_number ):
			var next_page_idx = randi() % loaded_pages_list.size()
			pages_list.append( loaded_pages_list[ next_page_idx ] )
			loaded_pages_list.remove( next_page_idx )
	else: 
		pages_list = loaded_pages_list
		if max_pages > 0 and max_pages < pages_list.size(): 
			pages_list.resize( max_pages )
	current_pages_count = 0
	complete = false
	next_page()

func finish():
	complete = true
	hide_panel()

func load_data( data_id ):
	var server_host = "127.0.0.1"
	if Globals.has( "server_host" ): server_host = Globals.get( "server_host" )
	var database = PSQLDatabase.new()
	database.connect_server( server_host, "gamedb", "postgres", "postgres" )
	loaded_pages_list = database.select( "public.pages", "id,text,options,image", \
	                                     "WHERE type='" + data_id + "' ORDER BY id" )
	print( loaded_pages_list )
	var image_file = File.new()
	for page_idx in range( loaded_pages_list.size() ):
		if loaded_pages_list[ page_idx ].has( "image" ):
			var image_buffer = loaded_pages_list[ page_idx ][ "image" ]
			image_file.open( "cache.png", File.WRITE )
			image_file.store_buffer( image_buffer )
			image_file.close()
			loaded_pages_list[ page_idx ][ "image" ] = ImageTexture.new()
			loaded_pages_list[ page_idx ][ "image" ].load( "cache.png" )
		else:
			loaded_pages_list[ page_idx ][ "image" ] = null
		print( loaded_pages_list[ page_idx ] )

func next_page():
	option_buttons.clear()
	right_option = -1
	current_pages_count += 1
	if current_pages_count > pages_list.size():
		content_image.set_texture( null )
		content_text.set_text( "" )
		finish()
		return
	var page_idx = current_pages_count - 1
	var page = pages_list[ page_idx ]
	print( page )
	content_text.set_text( page[ "text" ] )
	content_image.set_texture( page[ "image" ] )
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
	if option_buttons.get_button_count() > 0:
		if option_buttons.get_selected() == right_option: score += 1
		print( "total score: " + str(score) )
	next_page()
