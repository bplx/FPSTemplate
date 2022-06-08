extends KinematicBody

var weapons

var target
var path = []
var path_node = 0
export var Sprint_Speed = 4
export var Normal_Speed = 2
export var GRAVITY = 10
export var JUMPFORCE = 10
onready var player = get_node("/root/World/Player")
onready var nav = get_parent()
onready var head = $Head
onready var hand = $Head/Hand
onready var shootraycast = $Head/shootraycast
onready var healthbar = $Health/Viewport/HealthBar

var health = 80
var active = true
var dead = false
var selectedweapon = 1
var SPEED = 10
var mouse_sensitivity = 0.01 / 2

var velocity = Vector3(0, 0, 0)

func _ready():
	give_weapon("M14")
	give_weapon("Pistol")
	give_weapon("Sword")

func get_gun_count():
	var count = 0
	for i in weapons:
		if typeof(i) != TYPE_STRING:
			count += 1
	return count

func choose_weapon():
	
	# weapon code goes here
	
	if selectedweapon == 1:
		selectedweapon = 2
	if selectedweapon == 2:
		selectedweapon = 3
	if selectedweapon == 3:
		selectedweapon = 1
		
func get_gun_type(index):
	return hand.get_child(index).MODE
		
func activate_gun(index):
	if weapons[index] != null:
		if typeof(weapons[index]) != TYPE_STRING:
			if typeof(weapons[index]) != TYPE_INT:
				weapons[index].active = true
		
func deactivate_gun(index):
	if weapons[index] != null:
		if typeof(weapons[index]) != TYPE_STRING:
			if typeof(weapons[index]) != TYPE_INT:
				weapons[index].active = false

func delete_gun(index):
	if typeof(weapons[index]) != TYPE_STRING:
		if hand.get_child_count() >= index:
			if hand.get_child(index) != null:
				hand.get_child(index).queue_free()
				weapons[index] = "none"

func selected_weapon_manager():

	if selectedweapon == 1:
		activate_gun(0)
		deactivate_gun(1)
		deactivate_gun(2)

	if selectedweapon == 2:
		activate_gun(1)
		deactivate_gun(0)
		deactivate_gun(2)

	if selectedweapon == 3:
		activate_gun(2)
		deactivate_gun(0)
		deactivate_gun(1)



func gun_check_collision(shootrange):
	shootraycast.cast_to = Vector3(0, 0, shootrange)
	shootraycast.force_raycast_update()
	return shootraycast.get_collider()
	
func check_for_weapon(name):
	for i in hand.get_children():
		if i.name == name:
			return true
	return false

func get_weapon(name):
	return Guns.guns[name]
	
func give_weapon(name):
	if !check_for_weapon(name):
		if hand.get_child_count() <= 2:
			var gun_to_give = get_weapon(name)
			var instancedgun = gun_to_give.instance()
			hand.add_child(instancedgun)

func get_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func handle_input(delta):
	var input_dir = Vector3(0, 0, 0)
	
	# navigation here!
	input_dir.x += 1
		
	input_dir = input_dir.normalized()
	return input_dir
	
func handle_mouse_movement(ev):
	var rotationY = ev.relative.x * mouse_sensitivity
	var rotationX = ev.relative.y * mouse_sensitivity
	
	$Head.rotate_x(rotationX)
	rotate_y(-rotationY)
	
	$Head.rotation.x = clamp($Head.rotation.x, -1.2, 1.2)

func _physics_process(delta):
	if active == true:
		if dead == false:

					
			visible = true
			weapons = ["filler", 1, 2]
			
			if health <= 0:
				dead = true

			print(health)
			
			if hand.get_child_count() > 0:
				weapons[0] = hand.get_child(0)
			else:
				weapons[0] = "none"
			if hand.get_child_count() > 1:
				weapons[1] = hand.get_child(1)
			else:
				weapons[1] = "none"
			if hand.get_child_count() >= 3:
				weapons[2] = hand.get_child(2)
			else:
				weapons[2] = "none"

			choose_weapon()
			selected_weapon_manager()
			
			
			SPEED = Normal_Speed * 5

			velocity.y -= GRAVITY

			#velocity.x += handle_input(delta).x * SPEED
			#velocity.y += handle_input(delta).y * JUMPFORCE
			#velocity.z += handle_input(delta).z * SPEED
			
			velocity.x = velocity.x * 0.8
			velocity.z = velocity.z * 0.8
			

			if path_node < path.size():
				var direction = (path[path_node] - global_transform.origin)
				if direction.length() < 1:
					path_node += 1
				else:
					move_and_slide(direction.normalized() * SPEED, Vector3.UP)
			look_at(player.global_transform.origin, Vector3.UP)
			self.rotate_object_local(Vector3(0,1,0), 3.14)
			rotation.x = 0
			healthbar.value = health
		elif dead == true:
			healthbar.value = 0
			visible = false
	else:
		pass


func _on_Timer_timeout():
	get_to(player.global_transform.origin)
	
	#$Head.look_at(player.global_transform.origin, Vector3.UP)
	
	pass # Replace with function body.
