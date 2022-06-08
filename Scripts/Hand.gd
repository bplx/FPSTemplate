extends Spatial

const ADS_LERP = 20

export var player_path : NodePath
export var camera_path : NodePath
var camera : Camera
var player : KinematicBody
var swap
var zoomed
var swaptimeout = 0.1
export var default_position : Vector3
export var ads_position : Vector3

var fview = {"Default": 70, "ADS": 50}

func _ready():
	player = get_node(player_path)
	camera = get_node(camera_path)
	pass 
	
func _process(delta):
	var gun_type = player.get_gun_type(player.get("selectedweapon") - 1)

	if gun_type != "Melee":
		if Input.is_action_pressed("Secondary_Fire"):
			zoomed = true
		else: 
			zoomed = false
	else:
		zoomed = false

	if swap == true:
		transform.origin = transform.origin.linear_interpolate(default_position, swaptimeout)
		camera.fov = lerp(camera.fov, fview["Default"], swaptimeout)
		yield(get_tree().create_timer(swaptimeout), "timeout")
		swap = false
		
	if zoomed == true:
		transform.origin = transform.origin.linear_interpolate(ads_position, ADS_LERP * delta)
		camera.fov = lerp(camera.fov, fview["ADS"], ADS_LERP * delta)
	else:
		transform.origin = transform.origin.linear_interpolate(default_position, ADS_LERP * delta)
		camera.fov = lerp(camera.fov, fview["Default"], ADS_LERP * delta)
		
