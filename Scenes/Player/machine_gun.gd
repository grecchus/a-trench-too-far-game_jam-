extends Node2D

@onready var bullet_scene = preload("res://Scenes/World/bullet.tscn")

var rng := RandomNumberGenerator.new()
@onready var fire_rate := 0.05
@export var accuracy := 0.95
@onready var angle_spread := 90.0*(1 - accuracy)
var can_shoot := true

var targets_queue : Array

func _process(delta: float) -> void:
	
	if(not targets_queue.is_empty()):
		if(targets_queue.front() == null):
			targets_queue.remove_at(0)
			return
		
		var look_dir = 2*self.global_position - targets_queue.front().global_position
		$Weapon.look_at(look_dir)
		var shooting_dir =  targets_queue.front().global_position - self.global_position
		if(can_shoot): shoot(shooting_dir.normalized())

func shoot(direction):
	rng.randomize()
	if($Gunshot.playing): return
	var bullet : CharacterBody2D = bullet_scene.instantiate()
	add_child(bullet)
	var barrel_offset : Vector2 =  $Muzzle.position
	var angle = asin(direction.y) + deg_to_rad(rng.randf_range(-angle_spread,angle_spread))
	var dir = Vector2(sign(direction.x)*cos(angle), sin(angle))
	bullet.setup_bullet(self.global_position, dir, bullet.SIDE.ENEMY, barrel_offset, 2.0)
	
	can_shoot = false
	$FireRate.wait_time = fire_rate
	$FireRate.start()
	
	$Gunshot.play()


func _on_fire_rate_timeout() -> void:
	can_shoot = true


func _on_firing_range_body_entered(body: Node2D) -> void:
	if(not targets_queue.has(body)):
		targets_queue.append(body)
