extends RigidBody

var view_sensitivity = 0.3

var selecting_stage = false
var current_stage = null

const WALK_SPEED = 3;
const MAX_ACCEL = 0.02;
const AIR_ACCEL = 0.1;

func _ready():
	set_process_input( true )
	set_fixed_process( true )

func _input( event ):
	selecting_stage = false
	if event.type == InputEvent.MOUSE_MOTION:
		var body = get_node( "body" )
		var camera = get_node( "body/camera" )
		
		var yaw = rad2deg( body.get_rotation().y )
		var pitch = rad2deg( camera.get_rotation().x )
		
		yaw = fmod( yaw - event.relative_x * view_sensitivity, 360 )
		pitch = max( min( pitch - event.relative_y * view_sensitivity, 90 ), -90 )
		
		body.set_rotation( Vector3( 0, deg2rad( yaw ), 0 ) )
		camera.set_rotation( Vector3( deg2rad( pitch ), 0, 0 ) )
	elif event.type == InputEvent.MOUSE_BUTTON and event.pressed and event.button_index == 1:
		selecting_stage = true

func _fixed_process( delta ):
	var selector = get_node( "body/camera/selector" )
	if selector.is_colliding():
		current_stage = selector.get_collider().get_parent().get_parent()
		current_stage.activate()
		if selecting_stage:
			print( "selecting " + current_stage.get_name() )
			current_stage.select()
			selecting_stage = false
	elif current_stage != null:
		current_stage.deactivate()
		current_stage = null

func _integrate_forces( state ):
	var aim = get_node( "body" ).get_global_transform().basis
	var direction = Vector3()
	
	if Input.is_key_pressed( KEY_W ):
		direction -= aim[ 2 ]
	if Input.is_key_pressed( KEY_S ):
		direction += aim[ 2 ]
	if Input.is_key_pressed( KEY_A ):
		direction -= aim[ 0 ]
	if Input.is_key_pressed( KEY_D ):
		direction += aim[ 0 ]
	direction = direction.normalized()
	
	var ground_contact = get_node( "ground_contact" )
	if ground_contact.is_colliding():
		var up = state.get_total_gravity().normalized()
		var normal = ground_contact.get_collision_normal()
		
		var diff = direction * WALK_SPEED - state.get_linear_velocity()
		var vertdiff = aim[ 1 ] * diff.dot( aim[ 1 ] )
		diff -= vertdiff
		diff = diff.normalized() * clamp( diff.length(), 0, MAX_ACCEL / state.get_step() )
		diff += vertdiff
		apply_impulse( Vector3(), diff * get_mass() )
	else:
		apply_impulse( Vector3(), direction * AIR_ACCEL * get_mass() )
		
	state.integrate_forces()

func _enter_tree():
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )

func _exit_tree():
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
