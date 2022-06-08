
extends Sprite3D

func _ready():
	var enemy = $".."
	$Viewport/HealthBar.value = enemy.health
	texture = $Viewport.get_texture()
