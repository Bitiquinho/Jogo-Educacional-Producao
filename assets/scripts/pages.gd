extends Panel

onready var content_text = get_node( "content/text" )
onready var content_image = get_node( "content/image" )
onready var option_buttons = get_node( "option_buttons" )

onready var next_button = get_node( "next_button" )

var pages_list = []
var loaded_pages_list = []
var current_pages_count = 0
var random = false

var score = 0
var question_value = 1
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

func start( max_pages, random_pages, questions_value ):
	show_panel()
	if random_pages: 
		randomize()
		var pages_number = min( max_pages, loaded_pages_list.size() )
		for page_idx in range( pages_number ):
			var next_page_idx = randi() % loaded_pages_list.size()
			pages_list.append( loaded_pages_list[ next_page_idx ] )
			loaded_pages_list.remove( next_page_idx )
	else: 
		pages_list += loaded_pages_list
		if max_pages > 0 and max_pages < pages_list.size(): 
			pages_list.resize( max_pages )
	question_value = questions_value
	next_button.set_text( "Continuar" )
	complete = false
	current_pages_count = 0
	next_page()

func finish():
	if current_pages_count > pages_list.size(): complete = true
	hide_panel()

func load_data( data_id ):
	var database = PSQLDatabase.new()
	database.connect_server( Globals.get( "server_host" ), "gamedb", "postgres", "postgres" )
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
	if option_buttons.get_button_count() > 0:
		if option_buttons.get_selected() == right_option: score += question_value
	option_buttons.clear()
	right_option = -1
	current_pages_count += 1
	if current_pages_count < 0 or current_pages_count > pages_list.size():
		content_image.set_texture( null )
		content_text.set_text( "" )
		finish()
		return
	elif current_pages_count == pages_list.size():
		next_button.set_text( "Sair" )
	var page_idx = current_pages_count - 1
	var page = pages_list[ page_idx ]
	content_text.set_text( page[ "text" ] )
	content_image.set_texture( page[ "image" ] )
	var option_entries = page[ "options" ].split( ",", false )
	for entry_idx in range( option_entries.size() ):
		var entry = option_entries[ entry_idx ]
		if entry.find( "*" ) == 0: 
			right_option = entry_idx
			entry = entry.substr( 1, entry.length() - 1 )
		option_buttons.add_button( entry )

func _on_next_button_pressed():
	next_page()
