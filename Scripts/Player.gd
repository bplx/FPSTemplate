extends KinematicBody

var weapons

export var Sprint_Speed = 4
export var Normal_Speed = 2
export var GRAVITY = 10
export var JUMPFORCE = 10
onready var head = $Head
onready var hand = $Head/Hand
onready var shootraycast = $Head/shootraycast
onready var healthbar = $HUD/NormalHUD/HealthBar

var health = 100
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
	
	if Input.is_action_just_pressed("Weapon 1"):
		if typeof(weapons[0]) != TYPE_STRING and selectedweapon != 1:
			hand.swap = true
			selectedweapon = 1
	if Input.is_action_just_pressed("Weapon 2"):
		if typeof(weapons[1]) != TYPE_STRING and selectedweapon != 2:
			hand.swap = true
			selectedweapon = 2
	if Input.is_action_just_pressed("Weapon 3"):
		if typeof(weapons[2]) != TYPE_STRING and selectedweapon != 3:
			hand.swap = true
			selectedweapon = 3
		
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
	if active == true:
		if dead == false:
			$HUD/NormalHUD.visible = true
			$HUD/DeadHUD.visible = false
			healthbar.value = health
			weapons = ["filler", 1, 2]
			
			if health <= 0:
				dead = true

			print(dead)
			
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

			velocity.x += handle_input(delta).x * SPEED
			velocity.y += handle_input(delta).y * JUMPFORCE
			velocity.z += handle_input(delta).z * SPEED
			
			velocity.x = velocity.x * 0.8
			velocity.z = velocity.z * 0.8
			
			velocity = move_and_slide(velocity, Vector3.UP)
		elif dead == true:
			$CollisionShape.disabled = true
			visible = false
			$HUD/DeadHUD.visible = true
			$HUD/NormalHUD.visible = false
	else:
		$CollisionShape.disabled = true
		visible = false
		pass
func _input(event):
	if active == true:
		if dead == false:
			if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				handle_mouse_movement(event)
			
			if event is InputEventMouseButton:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		if Input.is_action_just_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	
