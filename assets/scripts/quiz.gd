extends Panel

func _input( event ):
	if event.type == InputEvent.KEY:
		if event.pressed and event.scancode == KEY_BACKSPACE:
			hide()
			get_tree().set_pause( false )
			Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
			set_process_input( false )

func start():
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
	get_tree().set_pause( true )
	show()
	set_process_input( true )
