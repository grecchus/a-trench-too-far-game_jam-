extends Node2D

var rng = RandomNumberGenerator.new()

func _ready():
	await get_tree().create_timer(1.0).timeout
	open_fire()

func open_fire():
	var rifles : Array = get_children()
	rifles.erase($Sprite)
	for rifle in rifles:
		await get_tree().create_timer(rng.randf_range(0.5, 2.0)).timeout
		rifle.shoot()
