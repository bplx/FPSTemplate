extends Node
class_name Weapon
export var FIRE_RATE = 0.1
export var CLIP_SIZE = 5
export var RELOAD_RATE = 1
export var DAMAGE = 10
export var FIRE_RANGE = 10
export(String, "Filler", "Automatic", "Non automatic") var MODE

onready var player = $"../../.."
onready var ammocount = $"../../../HUD/Ammo"

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

func _process(_delta):
	ammocount.text = str(current_ammo) + "|" + str(CLIP_SIZE)
	
	if MODE == "Automatic":
		if Input.is_action_pressed("Primary Fire") and can_fire:
			if current_ammo > 0 and not reloading:
				fire()
			elif not reloading:
				reload()
	elif MODE == "Non automatic":
		if Input.is_action_just_pressed("Primary Fire") and can_fire:
			if current_ammo > 0 and not reloading:
				fire()
			elif not reloading:
				reload()
		
	if Input.is_action_just_pressed("reload") and not reloading:
		reload()

func reload():
	print("Reloading")
	reloading = true
	# play an animation?
	yield(get_tree().create_timer(RELOAD_RATE), "timeout")
	current_ammo = CLIP_SIZE
	reloading = false
	print("Ok, done reloading")

func fire():
	print("Fired weapon")
	can_fire = false
	current_ammo -= 1
	$AnimationPlayer.stop(true)
	$AnimationPlayer.play("fire")
	
	var hit = player.gun_check_collision(FIRE_RANGE)
	if hit != null:
		print(hit.name)
		hit.queue_free()
	# do whatever
	
	yield(get_tree().create_timer(FIRE_RATE), "timeout")
	can_fire = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
