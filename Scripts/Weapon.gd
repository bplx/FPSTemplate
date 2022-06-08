extends Node
class_name Weapon
export var FIRE_RATE = 0.1
export var CLIP_SIZE = 5
export var RELOAD_RATE = 0.5
export var DAMAGE = 10
export var FIRE_RANGE = 10
export var Name : String
export(String, "Filler", "Automatic", "Non automatic", "Melee") var MODE

onready var player = $"../../.."
onready var ammocount1 = $"../../../HUD/NormalHUD/Ammo1"
onready var ammocount2 = $"../../../HUD/NormalHUD/Ammo2"
onready var namelabel = $"../../../HUD/NormalHUD/Name"

var hit
var swinging = false
var active = true
var dead = false
var can_fire = true
var reloading = false
var current_ammo = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("weapon class loaded")
	current_ammo = CLIP_SIZE
	pass # Replace with function body.

func _on_Area_body_entered(body):
	if swinging:
		if body.name != "Player":
			hit = body

func _process(_delta):
	if active:
		

		
		if player.name != "Enemy":
			if player.dead == true:
				active = false
		
		self.visible = true
		if player.name != "Enemy":
			namelabel.text = Name
			if MODE != "Melee":
				ammocount1.text = str(current_ammo)
				ammocount2.text = str(CLIP_SIZE)
			else:
				ammocount1.text = "-"
				ammocount2.text = "-"
		
		if MODE == "Automatic":
			if player.name != "Enemy":
				if Input.is_action_pressed("Primary Fire") and can_fire:
					if current_ammo > 0 and not reloading:
						fire()
					elif not reloading:
						reload()
						
		elif MODE == "Non automatic" or MODE == "Melee":
			if player.name != "Enemy":
				if Input.is_action_just_pressed("Primary Fire") and can_fire:
					if current_ammo > 0 and not reloading:
						fire()
					elif not reloading:
						reload()
				
		if player.name == "Enemy":
			if can_fire and player.dead != true:
				if current_ammo > 0 and not reloading:
					fire()
				elif not reloading:
					reload()
						
		if player.name != "Enemy":
			if Input.is_action_just_pressed("reload") and not reloading:
				reload()
	else: 
		self.visible = false

func reload():
	print("Reloading")
	reloading = true
	$AnimationPlayer.stop()
	$AnimationPlayer.play("reload")
	# play an animation?
	yield(get_tree().create_timer(RELOAD_RATE), "timeout")
	current_ammo = CLIP_SIZE
	reloading = false
	print("Ok, done reloading")

func fire():
	print("Fired weapon")
	can_fire = false
	swinging = false

	hit = null
	if MODE != "Melee":
		current_ammo -= 1
		
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("fire")
		hit = player.gun_check_collision(FIRE_RANGE)

		if hit != null:
			if hit.is_in_group("Enemies"):
				if hit.is_in_group("Enemies"):
					if hit.health - DAMAGE < 0:
						hit.health = 0
					else:
						hit.health -= DAMAGE
			if hit.name == "Player":
				hit.health -= DAMAGE
		#yield(get_tree().create_timer(FIRE_RATE), "timeout")

	else:
		swinging = true
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("fire")
		yield(get_tree().create_timer($AnimationPlayer.get_animation('fire').length / 6), "timeout")
			
		hit = player.gun_check_collision(FIRE_RANGE)
		if hit != null:
			if hit.is_in_group("Enemies"):
				if hit.health - DAMAGE < 0:
					hit.health = 0
				else:
					hit.health -= DAMAGE
			
	swinging = false
	
	yield(get_tree().create_timer(FIRE_RATE), "timeout")
	can_fire = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
