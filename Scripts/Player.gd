extends KinematicBody
export var Sprint_Speed = 4
export var Normal_Speed = 2
export var GRAVITY = 10
export var JUMPFORCE = 10

var SPEED = 10
var mouse_sensitivity = 0.01 / 2

var velocity = Vector3(0, 0, 0)

func handle_input(delta):
	var input_dir = Vector3(0, 0, 0)
	
	if Input.is_action_pressed("Forward"):
		input_dir += global_transform.basis.z * delta
	if Input.is_action_pressed("Backward"):
		input_dir += -global_transform.basis.z * delta
	if Input.is_action_pressed("Left"):
		input_dir += global_transform.basis.x * delta
	if Input.is_action_pressed("Right"):
		input_dir += -global_transform.basis.x * delta
	if Input.is_action_pressed("Sprint"):
		SPEED = Sprint_Speed * 5
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		input_dir += global_transform.basis.y
		
	input_dir = input_dir.normalized()
	return input_dir
	
func handle_mouse_movement(ev):
	var rotationY = ev.relative.x * mouse_sensitivity
	var rotationX = ev.relative.y * mouse_sensitivity
	
	$Head.rotate_x(rotationX)
	rotate_y(-rotationY)
	
	$Head.rotation.x = clamp($Head.rotation.x, -1.2, 1.2)

func _physics_process(delta):
	SPEED = Normal_Speed * 5

	velocity.y -= GRAVITY

	velocity.x += handle_input(delta).x * SPEED
	velocity.y += handle_input(delta).y * JUMPFORCE
	velocity.z += handle_input(delta).z * SPEED
	
	velocity.x = velocity.x * 0.8
	velocity.z = velocity.z * 0.8
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
func _input(event):
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		handle_mouse_movement(event)
	
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	
