extends Panel

var paused = false

func _ready():
	get_node( "return_button" ).connect( "pressed", self, "resume_game" )
	get_node( "exit_button" ).connect( "pressed", self, "quit_game" )
	set_process_input( true );

func _input( event ):
	if event.type == InputEvent.KEY and event.pressed and event.scancode == KEY_ESCAPE:
		if paused == true: 
			resume_game()
		if paused == false:
			paused = true
			Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
			get_tree().set_pause( true )
			show()

func resume_game():
	hide()
	get_tree().set_pause( false )
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
	paused = false

func quit_game():
	get_tree().call_deferred( "quit" )