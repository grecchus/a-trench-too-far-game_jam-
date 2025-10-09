extends Node2D

@onready var bullet_scene = preload("res://Scenes/World/bullet.tscn")

var rng := RandomNumberGenerator.new()
@onready var fire_rate := 2.0
@export var accuracy := 0.80
@onready var angle_spread := 90.0*(1 - accuracy)

func shoot():
	rng.randomize()
	if($Gunshot.playing): return
	var direction = Vector2(-1.0, 0.0)
	var bullet : CharacterBody2D = bullet_scene.instantiate()
	add_child(bullet)
	var barrel_offset : Vector2 =  Vector2(0.0, 0.0)
	var angle = asin(direction.y) + deg_to_rad(rng.randf_range(-angle_spread,angle_spread))
	var dir = Vector2(sign(direction.x)*cos(angle), sin(angle))
	bullet.setup_bullet(self.global_position, dir, bullet.SIDE.ENEMY, barrel_offset, 2.0)
	
	$FireRate.wait_time = fire_rate
	$FireRate.start()
	
	#$Gunshot.play()


func _on_fire_rate_timeout() -> void:
	shoot()
